// client/src/pages/BudgetScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Trash2, AlertTriangle, Wallet, X } from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function BudgetScreen() {
  const [user, setUser] = useState(null);
  const [budgets, setBudgets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  
  const [category, setCategory] = useState('Food & Dining');
  const [limit, setLimit] = useState('');

  const navigate = useNavigate();

  useEffect(() => {
    loadBudgets();
  }, []);

  const loadBudgets = async () => {
    setLoading(true);
    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }
    setUser(userRes.data);

    const res = await ApiService.getBudgets(userRes.data.id);
    setLoading(false);
    if (res.success) {
      setBudgets(res.data);
    }
  };

  const handleAddBudget = async (e) => {
    e.preventDefault();
    if (!limit || parseFloat(limit) <= 0) return;

    const res = await ApiService.addBudget({
      user_id: user.id,
      category,
      amount: parseFloat(limit)
    });

    if (res.success) {
      setShowModal(false);
      setLimit('');
      loadBudgets();
    } else {
      alert(res.error || 'Failed to add budget');
    }
  };

  const handleDeleteBudget = async (id) => {
    if (!window.confirm('Delete this category budget?')) return;
    const res = await ApiService.deleteBudget(id);
    if (res.success) loadBudgets();
  };

  const totalLimit = budgets.reduce((sum, b) => sum + b.limit, 0);
  const totalSpent = budgets.reduce((sum, b) => sum + b.spent, 0);
  const totalPercent = totalLimit > 0 ? Math.min(100, Math.round((totalSpent / totalLimit) * 100)) : 0;

  const currSymbol = user?.currency === 'USD' ? '$' : user?.currency === 'EUR' ? '€' : '₹';

  return (
    <MainLayout title="Monthly Budget Planner" user={user}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* Total Monthly Budget Header Card */}
        <div className="mm-card-gradient" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <span style={{ fontSize: '14px', opacity: 0.85 }}>Total Monthly Allocated Budget</span>
            <h2 style={{ fontSize: '32px', fontWeight: '800', margin: '8px 0' }}>
              {currSymbol}{totalSpent.toLocaleString()} / {currSymbol}{totalLimit.toLocaleString()}
            </h2>
            <span style={{ fontSize: '13px', opacity: 0.9 }}>
              Overall {totalPercent}% spent of monthly limits
            </span>
          </div>

          <button 
            onClick={() => setShowModal(true)}
            className="mm-btn-secondary"
            style={{ width: 'auto', padding: '12px 24px', background: 'rgba(255,255,255,0.15)', color: '#fff', border: 'none' }}
          >
            <Plus size={18} /> Set Category Budget
          </button>
        </div>

        {/* Budgets Grid */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
            Loading monthly budgets...
          </div>
        ) : budgets.length === 0 ? (
          <div className="mm-card" style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
            <Wallet size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '18px', color: '#fff', marginBottom: '8px' }}>No Budgets Created</h3>
            <p style={{ fontSize: '14px', marginBottom: '20px' }}>Set monthly spending limits for categories like Food, Shopping, Utilities.</p>
            <button onClick={() => setShowModal(true)} className="mm-btn-primary" style={{ width: 'auto', margin: '0 auto' }}>
              Create First Category Budget
            </button>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))',
            gap: '20px'
          }}>
            {budgets.map((b) => {
              const pct = b.limit > 0 ? Math.min(100, Math.round((b.spent / b.limit) * 100)) : 0;
              const isOver = b.spent > b.limit;

              return (
                <div key={b.id} className="mm-card" style={{
                  borderColor: isOver ? 'rgba(255, 77, 106, 0.4)' : 'var(--border)'
                }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <strong style={{ fontSize: '16px', color: 'var(--text-primary)' }}>{b.category}</strong>
                      {isOver && (
                        <span className="mm-badge mm-badge-red">
                          <AlertTriangle size={12} /> Exceeded Limit
                        </span>
                      )}
                    </div>
                    <button 
                      onClick={() => handleDeleteBudget(b.id)}
                      style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
                    >
                      <Trash2 size={18} />
                    </button>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '10px' }}>
                    <span>Spent: <strong style={{ color: isOver ? 'var(--accent-red)' : 'var(--text-primary)' }}>{currSymbol}{b.spent}</strong></span>
                    <span>Limit: {currSymbol}{b.limit}</span>
                  </div>

                  <div style={{ height: '10px', background: 'var(--bg-dark)', borderRadius: '5px', overflow: 'hidden' }}>
                    <div style={{
                      height: '100%',
                      width: `${pct}%`,
                      background: isOver ? 'var(--accent-red)' : 'var(--primary-gradient)',
                      transition: 'width 0.3s ease'
                    }} />
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Modal: Add Budget */}
        {showModal && (
          <div style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(5px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 1000, padding: '20px'
          }}>
            <div className="mm-card" style={{ width: '100%', maxWidth: '440px', background: 'var(--bg-card)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Set Category Limit</h3>
                <button onClick={() => setShowModal(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleAddBudget}>
                <div className="mm-input-group">
                  <label className="mm-input-label">Category</label>
                  <select 
                    className="mm-input" 
                    value={category} 
                    onChange={(e) => setCategory(e.target.value)}
                  >
                    {['Food & Dining', 'Shopping', 'Transportation', 'Housing & Rent', 'Entertainment', 'Bills & Utilities'].map((cat, i) => (
                      <option key={i} value={cat} style={{ background: '#111827' }}>{cat}</option>
                    ))}
                  </select>
                </div>

                <div className="mm-input-group">
                  <label className="mm-input-label">Monthly Limit ({currSymbol})</label>
                  <input 
                    type="number"
                    className="mm-input"
                    placeholder="10000"
                    value={limit}
                    onChange={(e) => setLimit(e.target.value)}
                    required
                  />
                </div>

                <button type="submit" className="mm-btn-primary" style={{ width: '100%', marginTop: '12px' }}>
                  Save Budget Limit
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
