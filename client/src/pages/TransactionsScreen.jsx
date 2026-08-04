// client/src/pages/TransactionsScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, ArrowDownRight, ArrowUpRight, Trash2, ListFilter } from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function TransactionsScreen() {
  const [user, setUser] = useState(null);
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterType, setFilterType] = useState('all');
  const [search, setSearch] = useState('');

  const navigate = useNavigate();

  useEffect(() => {
    loadTransactions();
  }, [filterType]);

  const loadTransactions = async () => {
    setLoading(true);
    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }
    setUser(userRes.data);

    const filters = {};
    if (filterType !== 'all') filters.type = filterType;

    const res = await ApiService.getTransactions(userRes.data.id, filters);
    setLoading(false);
    if (res.success) {
      setTransactions(res.data);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this transaction entry?')) return;
    const res = await ApiService.deleteTransaction(id);
    if (res.success) loadTransactions();
  };

  const filteredTxns = transactions.filter(t => {
    const q = search.toLowerCase();
    return t.category.toLowerCase().includes(q) || (t.note && t.note.toLowerCase().includes(q));
  });

  const currSymbol = user?.currency === 'USD' ? '$' : user?.currency === 'EUR' ? '€' : '₹';

  return (
    <MainLayout title="All Transaction History" user={user}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* Controls Header */}
        <div className="mm-card" style={{ display: 'flex', gap: '16px', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap' }}>
          {/* Search Input */}
          <div style={{ position: 'relative', flex: 1, minWidth: '280px' }}>
            <Search size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
            <input 
              type="text"
              className="mm-input"
              style={{ paddingLeft: '48px' }}
              placeholder="Search history by category, note..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          {/* Filter Type Pills */}
          <div style={{ display: 'flex', gap: '8px' }}>
            {[
              { id: 'all', label: 'All Activity' },
              { id: 'expense', label: 'Expenses' },
              { id: 'income', label: 'Incomes' }
            ].map(f => (
              <button
                key={f.id}
                onClick={() => setFilterType(f.id)}
                style={{
                  padding: '10px 20px',
                  borderRadius: '12px',
                  border: '1px solid var(--border)',
                  background: filterType === f.id ? 'var(--primary)' : 'var(--bg-elevated)',
                  color: filterType === f.id ? '#fff' : 'var(--text-secondary)',
                  fontSize: '13px',
                  fontWeight: '600',
                  cursor: 'pointer'
                }}
              >
                {f.label}
              </button>
            ))}
          </div>
        </div>

        {/* Transactions Table / List */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
            Loading history...
          </div>
        ) : filteredTxns.length === 0 ? (
          <div className="mm-card" style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
            <ListFilter size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '18px', color: '#fff', marginBottom: '8px' }}>No transactions found</h3>
          </div>
        ) : (
          <div className="mm-card" style={{ padding: '8px 16px' }}>
            {filteredTxns.map((t, idx) => (
              <div 
                key={t.id} 
                style={{
                  padding: '16px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  borderBottom: idx < filteredTxns.length - 1 ? '1px solid var(--border)' : 'none'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                  <div style={{
                    width: '44px', height: '44px', borderRadius: '14px',
                    background: t.type === 'income' ? 'rgba(0, 212, 170, 0.15)' : 'rgba(255, 77, 106, 0.15)',
                    color: t.type === 'income' ? 'var(--primary)' : 'var(--accent-red)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                  }}>
                    {t.type === 'income' ? <ArrowDownRight size={22} /> : <ArrowUpRight size={22} />}
                  </div>
                  <div>
                    <strong style={{ fontSize: '15px', color: 'var(--text-primary)', display: 'block' }}>{t.category}</strong>
                    <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                      {t.note ? `${t.note} • ` : ''}{t.txn_date}
                    </span>
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                  <span style={{
                    fontSize: '17px', fontWeight: '700',
                    color: t.type === 'income' ? 'var(--primary)' : 'var(--text-primary)'
                  }}>
                    {t.type === 'income' ? '+' : '-'}{currSymbol}{t.amount.toLocaleString()}
                  </span>

                  <button 
                    onClick={() => handleDelete(t.id)}
                    style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', padding: '6px' }}
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </MainLayout>
  );
}
