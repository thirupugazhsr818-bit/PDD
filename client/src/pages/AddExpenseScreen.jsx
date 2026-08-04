// client/src/pages/AddExpenseScreen.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ArrowLeft, Check, Calendar, FileText, 
  ShoppingBag, Utensils, Car, Home as HomeIcon, 
  Film, Zap, Gift, Briefcase 
} from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function AddExpenseScreen() {
  const [user, setUser] = useState(null);
  const [type, setType] = useState('expense');
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState('Food & Dining');
  const [note, setNote] = useState('');
  const [txnDate, setTxnDate] = useState(new Date().toISOString().split('T')[0]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const navigate = useNavigate();

  const categories = [
    { label: 'Food & Dining', icon: Utensils, color: '#FF4D6A' },
    { label: 'Shopping', icon: ShoppingBag, color: '#4D9FFF' },
    { label: 'Transportation', icon: Car, color: '#F5C842' },
    { label: 'Housing & Rent', icon: HomeIcon, color: '#9B6DFF' },
    { label: 'Entertainment', icon: Film, color: '#00D4AA' },
    { label: 'Bills & Utilities', icon: Zap, color: '#FF9900' },
    { label: 'Salary / Income', icon: Briefcase, color: '#00D4AA' },
    { label: 'Gift / Bonus', icon: Gift, color: '#FF4D6A' },
  ];

  useEffect(() => {
    ApiService.getCurrentUser().then(res => {
      if (res.success) setUser(res.data);
      else navigate('/login');
    });
  }, [navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!amount || parseFloat(amount) <= 0) {
      setError('Please enter a valid amount');
      return;
    }

    setLoading(true);
    setError('');

    const res = await ApiService.addTransaction({
      user_id: user.id,
      type,
      amount: parseFloat(amount),
      category,
      note,
      txn_date: txnDate
    });

    setLoading(false);

    if (res.success) {
      navigate('/home');
    } else {
      setError(res.error || 'Failed to add transaction');
    }
  };

  const getCurrencySymbol = (curr) => {
    switch (curr) {
      case 'USD': return '$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '₹';
    }
  };

  const currSymbol = user ? getCurrencySymbol(user.currency) : '₹';

  return (
    <MainLayout title="Add New Transaction" showBack user={user}>
      <div style={{ maxWidth: '700px', margin: '0 auto' }}>
        {/* Type Toggle */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          background: 'var(--bg-card)',
          border: '1px solid var(--border)',
          borderRadius: '16px',
          padding: '6px',
          marginBottom: '24px'
        }}>
          <button
            onClick={() => { setType('expense'); setCategory('Food & Dining'); }}
            style={{
              padding: '14px',
              borderRadius: '12px',
              border: 'none',
              background: type === 'expense' ? 'var(--accent-red)' : 'transparent',
              color: type === 'expense' ? '#fff' : 'var(--text-secondary)',
              fontSize: '15px',
              fontWeight: '700',
              cursor: 'pointer',
              transition: 'all 0.2s ease'
            }}
          >
            Expense
          </button>
          <button
            onClick={() => { setType('income'); setCategory('Salary / Income'); }}
            style={{
              padding: '14px',
              borderRadius: '12px',
              border: 'none',
              background: type === 'income' ? 'var(--primary)' : 'transparent',
              color: type === 'income' ? '#fff' : 'var(--text-secondary)',
              fontSize: '15px',
              fontWeight: '700',
              cursor: 'pointer',
              transition: 'all 0.2s ease'
            }}
          >
            Income
          </button>
        </div>

        {error && (
          <div style={{
            background: 'rgba(255, 77, 106, 0.12)',
            border: '1px solid rgba(255, 77, 106, 0.3)',
            borderRadius: '14px',
            padding: '12px 16px',
            color: 'var(--accent-red)',
            fontSize: '13px',
            marginBottom: '20px'
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mm-card">
          {/* Amount Box */}
          <div style={{ textAlign: 'center', padding: '20px 0', borderBottom: '1px solid var(--border)', marginBottom: '24px' }}>
            <span style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '8px', display: 'block' }}>
              Transaction Amount ({currSymbol})
            </span>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px' }}>
              <span style={{ fontSize: '36px', fontWeight: '700', color: type === 'income' ? 'var(--primary)' : 'var(--accent-red)' }}>
                {currSymbol}
              </span>
              <input 
                type="number"
                step="0.01"
                placeholder="0.00"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                style={{
                  background: 'none',
                  border: 'none',
                  outline: 'none',
                  fontSize: '44px',
                  fontWeight: '800',
                  color: 'var(--text-primary)',
                  width: '240px',
                  textAlign: 'center'
                }}
                autoFocus
              />
            </div>
          </div>

          {/* Category Chips Grid */}
          <div style={{ marginBottom: '24px' }}>
            <label className="mm-input-label" style={{ marginBottom: '12px', display: 'block' }}>
              Category
            </label>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))',
              gap: '12px'
            }}>
              {categories.map((cat, i) => {
                const IconC = cat.icon;
                const isSelected = category === cat.label;
                return (
                  <div
                    key={i}
                    onClick={() => setCategory(cat.label)}
                    style={{
                      background: isSelected ? 'var(--bg-elevated)' : 'var(--bg-card)',
                      border: isSelected ? `2px solid ${cat.color}` : '1px solid var(--border)',
                      borderRadius: '14px',
                      padding: '14px',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      cursor: 'pointer',
                      transition: 'all 0.2s ease'
                    }}
                  >
                    <div style={{
                      width: '36px', height: '36px', borderRadius: '10px',
                      background: `${cat.color}22`,
                      color: cat.color,
                      display: 'flex', alignItems: 'center', justifyContent: 'center'
                    }}>
                      <IconC size={20} />
                    </div>
                    <span style={{
                      fontSize: '13px',
                      fontWeight: isSelected ? '700' : '500',
                      color: isSelected ? '#fff' : 'var(--text-secondary)'
                    }}>
                      {cat.label}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Date & Description inputs */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '16px' }}>
            <div className="mm-input-group">
              <label className="mm-input-label">Date</label>
              <div style={{ position: 'relative' }}>
                <Calendar size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                <input 
                  type="date"
                  className="mm-input"
                  style={{ paddingLeft: '48px' }}
                  value={txnDate}
                  onChange={(e) => setTxnDate(e.target.value)}
                />
              </div>
            </div>

            <div className="mm-input-group">
              <label className="mm-input-label">Description / Note</label>
              <div style={{ position: 'relative' }}>
                <FileText size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                <input 
                  type="text"
                  className="mm-input"
                  style={{ paddingLeft: '48px' }}
                  placeholder="Grocery shopping, salary credit..."
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                />
              </div>
            </div>
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="mm-btn-primary"
            style={{
              width: '100%',
              background: type === 'income' ? 'var(--primary-gradient)' : 'var(--red-gradient)',
              marginTop: '12px',
              padding: '16px'
            }}
          >
            {loading ? 'Saving...' : (
              <>
                Save {type === 'income' ? 'Income' : 'Expense'} <Check size={20} />
              </>
            )}
          </button>
        </form>
      </div>
    </MainLayout>
  );
}
