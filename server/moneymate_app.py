from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, date
import json
import os
from pymongo import MongoClient, DESCENDING, ASCENDING
from bson import ObjectId

app = Flask(__name__)
CORS(app)

# ✅ Reads from MongoDB URI environment variable or defaults to MongoDB Atlas
mongo_uri = os.environ.get('MONGO_URI', 'mongodb+srv://yaduraj:yaduraj@cluster0.vsk89qe.mongodb.net/?appName=Cluster0')
client = MongoClient(mongo_uri)
db = client['moneymate']

# ─────────────────────────────────────────
# HELPER FUNCTIONS FOR AUTO-INCREMENT IDS
# ─────────────────────────────────────────
def get_next_sequence(name):
    doc = db.counters.find_one_and_update(
        {'_id': name},
        {'$inc': {'seq': 1}},
        upsert=True,
        return_document=True
    )
    return doc['seq']

def format_date(val):
    if isinstance(val, (datetime, date)):
        return val.strftime('%d %b %Y')
    return str(val) if val else None

# ─────────────────────────────────────────
# AUTH
# ─────────────────────────────────────────

@app.route('/signup', methods=['POST'])
def signup():
    try:
        data = request.get_json()
        required = ['name', 'email', 'phone', 'password', 'confirm_password']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
        if data['password'] != data['confirm_password']:
            return jsonify({'error': 'Passwords do not match'}), 400
        
        if db.users.find_one({'email': data['email']}):
            return jsonify({'error': 'Email already registered'}), 409
        
        user_id = get_next_sequence('user_id')
        user_doc = {
            'id': user_id,
            'name': data['name'],
            'email': data['email'],
            'phone': data['phone'],
            'password': generate_password_hash(data['password']),
            'currency': data.get('currency', 'INR'),
            'created_at': datetime.utcnow()
        }
        db.users.insert_one(user_doc)
        return jsonify({'message': 'User registered successfully', 'id': user_id}), 201
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({'error': 'Email and password required'}), 400
        
        user = db.users.find_one({'email': data['email']})
        if not user or not check_password_hash(user['password'], data['password']):
            return jsonify({'error': 'Invalid credentials'}), 401
        
        session_id = get_next_sequence('session_id')
        db.active_sessions.insert_one({
            'id': session_id,
            'email': user['email'],
            'login_at': datetime.utcnow()
        })
        
        return jsonify({'message': 'Login successful', 'user': {
            'id': user['id'], 'name': user['name'], 'email': user['email'],
            'phone': user['phone'], 'currency': user.get('currency', 'INR')
        }}), 200
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@app.route('/get_current_user', methods=['GET'])
def get_current_user():
    try:
        last = db.active_sessions.find_one(sort=[('id', DESCENDING)])
        if not last:
            return jsonify({'error': 'No active user found'}), 404
        user = db.users.find_one({'email': last['email']})
        if not user:
            return jsonify({'error': 'User not found'}), 404
        return jsonify({
            'id': user['id'], 'name': user['name'], 'email': user['email'],
            'phone': user['phone'], 'currency': user.get('currency', 'INR')
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/logout', methods=['POST'])
def logout():
    try:
        data = request.get_json()
        email = data.get('email') if data else None
        if not email:
            return jsonify({'error': 'Email required'}), 400
        db.active_sessions.delete_many({'email': email})
        return jsonify({'message': 'Logged out successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# PROFILE
# ─────────────────────────────────────────

@app.route('/profile/<int:user_id>', methods=['GET'])
def get_profile(user_id):
    try:
        user = db.users.find_one({'id': user_id})
        if not user:
            return jsonify({'error': 'User not found'}), 404
        created_at = user.get('created_at', datetime.utcnow())
        if isinstance(created_at, datetime):
            created_str = created_at.strftime('%d %b %Y')
        else:
            created_str = str(created_at)
        return jsonify({
            'id': user['id'], 'name': user['name'], 'email': user['email'],
            'phone': user['phone'], 'currency': user.get('currency', 'INR'),
            'created_at': created_str
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/profile/<int:user_id>', methods=['PUT'])
def update_profile(user_id):
    try:
        data = request.get_json() or {}
        user = db.users.find_one({'id': user_id})
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        update_fields = {}
        if 'name' in data: update_fields['name'] = data['name']
        if 'phone' in data: update_fields['phone'] = data['phone']
        if 'currency' in data: update_fields['currency'] = data['currency']
        
        if update_fields:
            db.users.update_one({'id': user_id}, {'$set': update_fields})
        return jsonify({'message': 'Profile updated'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# TRANSACTIONS
# ─────────────────────────────────────────

@app.route('/transactions/<int:user_id>', methods=['GET'])
def get_transactions(user_id):
    try:
        txn_type = request.args.get('type')
        category = request.args.get('category')
        month = request.args.get('month')
        limit = int(request.args.get('limit', 50))
        
        query = {'user_id': user_id}
        if txn_type:
            query['type'] = txn_type
        if category:
            query['category'] = category
        if month:
            query['month_key'] = month
            
        cursor = db.transactions.find(query).sort([('txn_date', DESCENDING), ('created_at', DESCENDING)]).limit(limit)
        
        result = []
        for t in cursor:
            txn_date_val = t.get('txn_date')
            if isinstance(txn_date_val, (datetime, date)):
                date_str = txn_date_val.strftime('%d %b %Y')
            elif isinstance(txn_date_val, str):
                try:
                    dt = datetime.strptime(txn_date_val, '%Y-%m-%d')
                    date_str = dt.strftime('%d %b %Y')
                except Exception:
                    date_str = txn_date_val
            else:
                date_str = ''

            result.append({
                'id': t['id'],
                'type': t['type'],
                'amount': float(t['amount']),
                'category': t['category'],
                'note': t.get('note', ''),
                'icon': t.get('icon', ''),
                'color': t.get('color', ''),
                'txn_date': date_str
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/transactions', methods=['POST'])
def add_transaction():
    try:
        data = request.get_json()
        required = ['user_id', 'type', 'amount', 'category']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
        if data['type'] not in ('expense', 'income'):
            return jsonify({'error': "type must be 'expense' or 'income'"}), 400
        
        if data.get('txn_date'):
            try:
                txn_date_obj = datetime.strptime(data['txn_date'], '%Y-%m-%d').date()
            except ValueError:
                txn_date_obj = date.today()
        else:
            txn_date_obj = date.today()

        month_key = txn_date_obj.strftime('%Y-%m')
        txn_id = get_next_sequence('txn_id')
        
        txn_doc = {
            'id': txn_id,
            'user_id': int(data['user_id']),
            'type': data['type'],
            'amount': float(data['amount']),
            'category': data['category'],
            'note': data.get('note', ''),
            'icon': data.get('icon', ''),
            'color': data.get('color', ''),
            'txn_date': datetime.combine(txn_date_obj, datetime.min.time()),
            'month_key': month_key,
            'created_at': datetime.utcnow()
        }
        db.transactions.insert_one(txn_doc)
        return jsonify({'message': 'Transaction saved', 'id': txn_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/transactions/<int:txn_id>', methods=['DELETE'])
def delete_transaction(txn_id):
    try:
        res = db.transactions.delete_one({'id': txn_id})
        if res.deleted_count == 0:
            return jsonify({'error': 'Transaction not found'}), 404
        return jsonify({'message': 'Transaction deleted'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/transactions/summary/<int:user_id>', methods=['GET'])
def get_summary(user_id):
    try:
        month = request.args.get('month', datetime.utcnow().strftime('%Y-%m'))
        txns = list(db.transactions.find({'user_id': user_id, 'month_key': month}))
        
        total_income = sum(float(t['amount']) for t in txns if t['type'] == 'income')
        total_expense = sum(float(t['amount']) for t in txns if t['type'] == 'expense')
        
        category_map = {}
        for t in txns:
            if t['type'] == 'expense':
                cat = t['category']
                if cat not in category_map:
                    category_map[cat] = {
                        'category': cat,
                        'icon': t.get('icon', ''),
                        'color': t.get('color', ''),
                        'total': 0.0
                    }
                category_map[cat]['total'] += float(t['amount'])
                
        return jsonify({
            'month': month,
            'total_income': round(total_income, 2),
            'total_expense': round(total_expense, 2),
            'net_balance': round(total_income - total_expense, 2),
            'categories': list(category_map.values())
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/transactions/monthly_chart/<int:user_id>', methods=['GET'])
def get_monthly_chart(user_id):
    try:
        pipeline = [
            {
                '$match': {
                    'user_id': user_id,
                    'type': 'expense'
                }
            },
            {
                '$group': {
                    '_id': '$month_key',
                    'total': {'$sum': '$amount'},
                    'sample_date': {'$first': '$txn_date'}
                }
            },
            {'$sort': {'_id': ASCENDING}}
        ]
        results = list(db.transactions.aggregate(pipeline))
        chart_data = []
        for r in results:
            month_key = r['_id']
            if not month_key: continue
            try:
                dt = datetime.strptime(month_key, '%Y-%m')
                month_name = dt.strftime('%b')
            except Exception:
                month_name = month_key
            chart_data.append({
                'month': month_name,
                'month_key': month_key,
                'total': round(float(r['total']), 2)
            })
        return jsonify(chart_data[-6:] if len(chart_data) > 6 else chart_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# BUDGETS
# ─────────────────────────────────────────

@app.route('/budgets/<int:user_id>', methods=['GET'])
def get_budgets(user_id):
    try:
        month = request.args.get('month', datetime.utcnow().strftime('%Y-%m'))
        budgets = list(db.budgets.find({'user_id': user_id, 'month': month}))
        result = []
        for b in budgets:
            txns = list(db.transactions.find({
                'user_id': user_id,
                'type': 'expense',
                'category': b['category'],
                'month_key': month
            }))
            spent = sum(float(t['amount']) for t in txns)
            result.append({
                'id': b['id'],
                'category': b['category'],
                'icon': b.get('icon', ''),
                'color': b.get('color', ''),
                'limit': float(b['amount']),
                'spent': float(spent),
                'month': b['month']
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/budgets', methods=['POST'])
def add_budget():
    try:
        data = request.get_json()
        required = ['user_id', 'category', 'amount']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
        month = data.get('month', datetime.utcnow().strftime('%Y-%m'))
        
        if db.budgets.find_one({'user_id': int(data['user_id']), 'category': data['category'], 'month': month}):
            return jsonify({'error': 'Budget for this category already exists this month'}), 409
            
        budget_id = get_next_sequence('budget_id')
        doc = {
            'id': budget_id,
            'user_id': int(data['user_id']),
            'category': data['category'],
            'icon': data.get('icon', ''),
            'color': data.get('color', ''),
            'amount': float(data['amount']),
            'month': month,
            'created_at': datetime.utcnow()
        }
        db.budgets.insert_one(doc)
        return jsonify({'message': 'Budget added', 'id': budget_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/budgets/<int:budget_id>', methods=['PUT'])
def update_budget(budget_id):
    try:
        data = request.get_json() or {}
        b = db.budgets.find_one({'id': budget_id})
        if not b:
            return jsonify({'error': 'Budget not found'}), 404
        if 'amount' in data:
            db.budgets.update_one({'id': budget_id}, {'$set': {'amount': float(data['amount'])}})
        return jsonify({'message': 'Budget updated'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/budgets/<int:budget_id>', methods=['DELETE'])
def delete_budget(budget_id):
    try:
        res = db.budgets.delete_one({'id': budget_id})
        if res.deleted_count == 0:
            return jsonify({'error': 'Budget not found'}), 404
        return jsonify({'message': 'Budget deleted'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# SAVINGS GOALS
# ─────────────────────────────────────────

@app.route('/savings_goals/<int:user_id>', methods=['GET'])
def get_savings_goals(user_id):
    try:
        goals = list(db.savings_goals.find({'user_id': user_id}).sort('created_at', DESCENDING))
        result = []
        for g in goals:
            target = float(g['target'])
            saved = float(g.get('saved', 0.0))
            updated_at = g.get('updated_at', g.get('created_at', datetime.utcnow()))
            result.append({
                'id': g['id'],
                'label': g['label'],
                'icon': g.get('icon', ''),
                'color': g.get('color', ''),
                'target': target,
                'saved': saved,
                'percent': round((saved / target) * 100, 1) if target > 0 else 0.0,
                'updated_at': format_date(updated_at)
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/savings_goals', methods=['POST'])
def add_savings_goal():
    try:
        data = request.get_json()
        required = ['user_id', 'label', 'target']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
            
        goal_id = get_next_sequence('savings_goal_id')
        doc = {
            'id': goal_id,
            'user_id': int(data['user_id']),
            'label': data['label'],
            'icon': data.get('icon', ''),
            'color': data.get('color', ''),
            'target': float(data['target']),
            'saved': float(data.get('saved', 0.0)),
            'created_at': datetime.utcnow(),
            'updated_at': datetime.utcnow()
        }
        db.savings_goals.insert_one(doc)
        return jsonify({'message': 'Goal created', 'id': goal_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/savings_goals/<int:goal_id>', methods=['PUT'])
def update_savings_goal(goal_id):
    try:
        data = request.get_json() or {}
        goal = db.savings_goals.find_one({'id': goal_id})
        if not goal:
            return jsonify({'error': 'Goal not found'}), 404
        update_fields = {'updated_at': datetime.utcnow()}
        if 'label' in data: update_fields['label'] = data['label']
        if 'target' in data: update_fields['target'] = float(data['target'])
        db.savings_goals.update_one({'id': goal_id}, {'$set': update_fields})
        return jsonify({'message': 'Goal updated'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/savings_goals/<int:goal_id>', methods=['DELETE'])
def delete_savings_goal(goal_id):
    try:
        res = db.savings_goals.delete_one({'id': goal_id})
        if res.deleted_count == 0:
            return jsonify({'error': 'Goal not found'}), 404
        db.savings_contributions.delete_many({'goal_id': goal_id})
        return jsonify({'message': 'Goal deleted'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/savings_goals/<int:goal_id>/add_money', methods=['POST'])
def add_money_to_goal(goal_id):
    try:
        data = request.get_json() or {}
        amount = data.get('amount')
        if not amount or float(amount) <= 0:
            return jsonify({'error': 'Valid amount required'}), 400
        goal = db.savings_goals.find_one({'id': goal_id})
        if not goal:
            return jsonify({'error': 'Goal not found'}), 404
            
        new_saved = float(goal.get('saved', 0.0)) + float(amount)
        db.savings_goals.update_one({'id': goal_id}, {
            '$set': {'saved': new_saved, 'updated_at': datetime.utcnow()}
        })
        
        contrib_id = get_next_sequence('contribution_id')
        db.savings_contributions.insert_one({
            'id': contrib_id,
            'goal_id': goal_id,
            'user_id': goal['user_id'],
            'amount': float(amount),
            'note': data.get('note', ''),
            'contributed_at': datetime.utcnow()
        })
        
        target = float(goal['target'])
        return jsonify({
            'message': 'Amount added',
            'saved': new_saved,
            'percent': round((new_saved / target) * 100, 1) if target > 0 else 0.0
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/savings_goals/<int:goal_id>/contributions', methods=['GET'])
def get_contributions(goal_id):
    try:
        contribs = list(db.savings_contributions.find({'goal_id': goal_id}).sort('contributed_at', DESCENDING))
        result = [{
            'id': c['id'],
            'amount': float(c['amount']),
            'note': c.get('note', ''),
            'contributed_at': format_date(c.get('contributed_at'))
        } for c in contribs]
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# EMI TRACKER
# ─────────────────────────────────────────

@app.route('/emis/<int:user_id>', methods=['GET'])
def get_emis(user_id):
    try:
        status = request.args.get('status', 'active')
        emis = list(db.emis.find({'user_id': user_id, 'status': status}).sort('due_day', ASCENDING))
        today = date.today()
        result = []
        for e in emis:
            due_day = int(e['due_day'])
            try:
                next_due = date(today.year, today.month, due_day)
            except ValueError:
                next_due = date(today.year, today.month, 28)
                
            if next_due < today:
                m = today.month + 1 if today.month < 12 else 1
                y = today.year if today.month < 12 else today.year + 1
                try:
                    next_due = date(y, m, due_day)
                except ValueError:
                    next_due = date(y, m, 28)
                    
            days_left = (next_due - today).days
            total_m = int(e['total_months'])
            paid_m = int(e.get('paid_months', 0))
            rem_m = max(0, total_m - paid_m)
            emi_amt = float(e['emi_amount'])
            outstanding = emi_amt * rem_m
            
            result.append({
                'id': e['id'],
                'label': e['label'],
                'icon': e.get('icon', ''),
                'color': e.get('color', ''),
                'bank': e.get('bank', ''),
                'emi_amount': emi_amt,
                'total_months': total_m,
                'paid_months': paid_m,
                'remaining_months': rem_m,
                'due_day': due_day,
                'days_left': days_left,
                'outstanding': round(outstanding, 2),
                'percent_paid': round((paid_m / total_m) * 100, 1) if total_m > 0 else 0.0,
                'status': e.get('status', 'active')
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/emis', methods=['POST'])
def add_emi():
    try:
        data = request.get_json()
        required = ['user_id', 'label', 'emi_amount', 'total_months', 'due_day']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
            
        emi_id = get_next_sequence('emi_id')
        doc = {
            'id': emi_id,
            'user_id': int(data['user_id']),
            'label': data['label'],
            'icon': data.get('icon', ''),
            'color': data.get('color', ''),
            'bank': data.get('bank', ''),
            'emi_amount': float(data['emi_amount']),
            'total_months': int(data['total_months']),
            'paid_months': int(data.get('paid_months', 0)),
            'due_day': int(data['due_day']),
            'status': 'active',
            'created_at': datetime.utcnow()
        }
        db.emis.insert_one(doc)
        return jsonify({'message': 'EMI added', 'id': emi_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/emis/<int:emi_id>/pay', methods=['POST'])
def mark_emi_paid(emi_id):
    try:
        emi = db.emis.find_one({'id': emi_id})
        if not emi:
            return jsonify({'error': 'EMI not found'}), 404
            
        paid_m = int(emi.get('paid_months', 0)) + 1
        total_m = int(emi['total_months'])
        status = 'closed' if paid_m >= total_m else emi.get('status', 'active')
        
        db.emis.update_one({'id': emi_id}, {
            '$set': {'paid_months': paid_m, 'status': status}
        })
        return jsonify({
            'message': 'EMI marked as paid',
            'paid_months': paid_m,
            'status': status
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/emis/<int:emi_id>', methods=['DELETE'])
def delete_emi(emi_id):
    try:
        res = db.emis.delete_one({'id': emi_id})
        if res.deleted_count == 0:
            return jsonify({'error': 'EMI not found'}), 404
        return jsonify({'message': 'EMI deleted'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# BILLS
# ─────────────────────────────────────────

@app.route('/bills/<int:user_id>', methods=['GET'])
def get_bills(user_id):
    try:
        is_paid_param = request.args.get('is_paid')
        query = {'user_id': user_id}
        if is_paid_param is not None:
            query['is_paid'] = bool(int(is_paid_param))
            
        bills = list(db.bills.find(query).sort('due_day', ASCENDING))
        today = date.today()
        result = []
        for b in bills:
            due_day = int(b['due_day'])
            try:
                due_date = date(today.year, today.month, due_day)
            except ValueError:
                due_date = date(today.year, today.month, 28)
            days_left = (due_date - today).days
            result.append({
                'id': b['id'],
                'label': b['label'],
                'icon': b.get('icon', ''),
                'color': b.get('color', ''),
                'amount': float(b['amount']),
                'due_day': due_day,
                'days_left': days_left,
                'is_paid': bool(b.get('is_paid', False))
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/bills', methods=['POST'])
def add_bill():
    try:
        data = request.get_json()
        required = ['user_id', 'label', 'amount', 'due_day']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
            
        bill_id = get_next_sequence('bill_id')
        doc = {
            'id': bill_id,
            'user_id': int(data['user_id']),
            'label': data['label'],
            'icon': data.get('icon', ''),
            'color': data.get('color', ''),
            'amount': float(data['amount']),
            'due_day': int(data['due_day']),
            'is_paid': False,
            'created_at': datetime.utcnow(),
            'updated_at': datetime.utcnow()
        }
        db.bills.insert_one(doc)
        return jsonify({'message': 'Bill added', 'id': bill_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/bills/<int:bill_id>/pay', methods=['POST'])
def mark_bill_paid(bill_id):
    try:
        res = db.bills.update_one({'id': bill_id}, {'$set': {'is_paid': True, 'updated_at': datetime.utcnow()}})
        if res.matched_count == 0:
            return jsonify({'error': 'Bill not found'}), 404
        return jsonify({'message': 'Bill marked as paid'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/bills/<int:bill_id>/unpay', methods=['POST'])
def mark_bill_unpaid(bill_id):
    try:
        res = db.bills.update_one({'id': bill_id}, {'$set': {'is_paid': False, 'updated_at': datetime.utcnow()}})
        if res.matched_count == 0:
            return jsonify({'error': 'Bill not found'}), 404
        return jsonify({'message': 'Bill marked as unpaid'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/bills/<int:bill_id>', methods=['DELETE'])
def delete_bill(bill_id):
    try:
        res = db.bills.delete_one({'id': bill_id})
        if res.deleted_count == 0:
            return jsonify({'error': 'Bill not found'}), 404
        return jsonify({'message': 'Bill deleted'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# GOALS (MILESTONE TRACKER)
# ─────────────────────────────────────────

@app.route('/goals/<int:user_id>', methods=['GET'])
def get_goals(user_id):
    try:
        goals = list(db.goals.find({'user_id': user_id}).sort('created_at', DESCENDING))
        result = []
        for g in goals:
            ms = g.get('milestones', [])
            if isinstance(ms, str):
                try: ms = json.loads(ms)
                except Exception: ms = []
            updated_at = g.get('updated_at', g.get('created_at', datetime.utcnow()))
            result.append({
                'id': g['id'],
                'label': g['label'],
                'icon': g.get('icon', ''),
                'color': g.get('color', ''),
                'progress': float(g.get('progress', 0.0)),
                'milestones': ms,
                'updated_at': format_date(updated_at)
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/goals', methods=['POST'])
def add_goal():
    try:
        data = request.get_json()
        required = ['user_id', 'label']
        if not data or not all(k in data for k in required):
            return jsonify({'error': 'Missing required fields'}), 400
            
        goal_id = get_next_sequence('goal_id')
        doc = {
            'id': goal_id,
            'user_id': int(data['user_id']),
            'label': data['label'],
            'icon': data.get('icon', ''),
            'color': data.get('color', ''),
            'progress': float(data.get('progress', 0.0)),
            'milestones': data.get('milestones', []),
            'created_at': datetime.utcnow(),
            'updated_at': datetime.utcnow()
        }
        db.goals.insert_one(doc)
        return jsonify({'message': 'Goal added', 'id': goal_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/goals/<int:goal_id>', methods=['PUT'])
def update_goal(goal_id):
    try:
        data = request.get_json() or {}
        goal = db.goals.find_one({'id': goal_id})
        if not goal:
            return jsonify({'error': 'Goal not found'}), 404
        update_fields = {'updated_at': datetime.utcnow()}
        if 'label' in data: update_fields['label'] = data['label']
        if 'progress' in data: update_fields['progress'] = float(data['progress'])
        if 'milestones' in data: update_fields['milestones'] = data['milestones']
        db.goals.update_one({'id': goal_id}, {'$set': update_fields})
        return jsonify({'message': 'Goal updated'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/goals/<int:goal_id>', methods=['DELETE'])
def delete_goal(goal_id):
    try:
        res = db.goals.delete_one({'id': goal_id})
        if res.deleted_count == 0:
            return jsonify({'error': 'Goal not found'}), 404
        return jsonify({'message': 'Goal deleted'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────
# DASHBOARD
# ─────────────────────────────────────────

@app.route('/dashboard/<int:user_id>', methods=['GET'])
def get_dashboard(user_id):
    try:
        month = request.args.get('month', datetime.utcnow().strftime('%Y-%m'))
        today = date.today()

        # Month txns
        month_txns = list(db.transactions.find({'user_id': user_id, 'month_key': month}))
        total_income = sum(float(t['amount']) for t in month_txns if t['type'] == 'income')
        total_expense = sum(float(t['amount']) for t in month_txns if t['type'] == 'expense')

        # Overall txns
        all_txns = list(db.transactions.find({'user_id': user_id}))
        all_income = sum(float(t['amount']) for t in all_txns if t['type'] == 'income')
        all_expense = sum(float(t['amount']) for t in all_txns if t['type'] == 'expense')

        # Recent 4 txns
        recent_txns = list(db.transactions.find({'user_id': user_id}).sort([('txn_date', DESCENDING), ('created_at', DESCENDING)]).limit(4))
        recent_formatted = []
        for t in recent_txns:
            txn_date_val = t.get('txn_date')
            if isinstance(txn_date_val, (datetime, date)):
                date_str = txn_date_val.strftime('%d %b %Y')
            elif isinstance(txn_date_val, str):
                date_str = txn_date_val
            else:
                date_str = ''

            recent_formatted.append({
                'id': t['id'],
                'type': t['type'],
                'amount': float(t['amount']),
                'category': t['category'],
                'note': t.get('note', ''),
                'icon': t.get('icon', ''),
                'color': t.get('color', ''),
                'txn_date': date_str
            })

        # Budgets data
        budgets_data = []
        month_budgets = list(db.budgets.find({'user_id': user_id, 'month': month}))
        for b in month_budgets:
            cat_txns = list(db.transactions.find({
                'user_id': user_id,
                'type': 'expense',
                'category': b['category'],
                'month_key': month
            }))
            spent = sum(float(t['amount']) for t in cat_txns)
            budgets_data.append({
                'category': b['category'],
                'icon': b.get('icon', ''),
                'color': b.get('color', ''),
                'limit': float(b['amount']),
                'spent': round(float(spent), 2)
            })

        # Savings total
        goals = list(db.savings_goals.find({'user_id': user_id}))
        total_saved = sum(float(g.get('saved', 0.0)) for g in goals)

        # Upcoming bills (due in next 7 days)
        upcoming_bills = []
        unpaid_bills = list(db.bills.find({'user_id': user_id, 'is_paid': False}))
        for b in unpaid_bills:
            due_day = int(b['due_day'])
            try:
                due_date = date(today.year, today.month, due_day)
            except ValueError:
                due_date = date(today.year, today.month, 28)
            days_left = (due_date - today).days
            if 0 <= days_left <= 7:
                upcoming_bills.append({
                    'id': b['id'],
                    'label': b['label'],
                    'icon': b.get('icon', ''),
                    'amount': float(b['amount']),
                    'days_left': days_left
                })

        return jsonify({
            'balance': round(all_income - all_expense, 2),
            'month_income': round(total_income, 2),
            'month_expense': round(total_expense, 2),
            'total_saved': round(total_saved, 2),
            'recent_transactions': recent_formatted,
            'budgets': budgets_data,
            'upcoming_bills': upcoming_bills
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
