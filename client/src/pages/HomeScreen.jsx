// client/src/pages/HomeScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  TrendingUp, TrendingDown, PiggyBank, CreditCard, 
  Receipt, Target, List, ArrowUpRight, ArrowDownRight, 
  AlertCircle, ChevronRight, Plus, Eye, EyeOff, Wallet 
} from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function HomeScreen() {
  const [user, setUser] = useState(null);
  const [dash, setDash] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showBalance, setShowBalance] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    setError('');

    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }
    setUser(userRes.data);

    const dashRes = await ApiService.getDashboard(userRes.data.id);
    setLoading(false);
    if (dashRes.success) {
      setDash(dashRes.data);
    } else {
      setError(dashRes.error || 'Failed to load dashboard data');
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
    <MainLayout title="Dashboard Overview" user={user}>
      {loading ? (
        <div style={{ textAlign: 'center', padding: '100px 0', color: 'var(--primary)' }}>
          <div className="pulse-glow" style={{
            width: '60px', height: '60px', borderRadius: '50%',
            background: 'var(--primary-gradient)', margin: '0 auto 20px'
          }} />
          <p style={{ color: 'var(--text-secondary)', fontSize: '15px' }}>Loading Financial Analytics...</p>
        </div>
      ) : error ? (
        <div style={{
          background: 'rgba(255, 77, 106, 0.12)',
          border: '1px solid rgba(255, 77, 106, 0.3)',
          borderRadius: '16px',
          padding: '24px',
          textAlign: 'center',
          color: 'var(--accent-red)'
        }}>
          <AlertCircle size={36} style={{ marginBottom: '10px' }} />
          <p style={{ fontSize: '15px', marginBottom: '16px' }}>{error}</p>
          <button onClick={loadData} className="mm-btn-secondary" style={{ width: 'auto', margin: '0 auto' }}>
            Retry
          </button>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
          {/* Top Row: Balance Banner & Quick Stats */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
            gap: '24px'
          }}>
            {/* Main Balance Card */}
            <div className="mm-card-gradient">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                <span style={{ fontSize: '14px', opacity: 0.85, fontWeight: '500' }}>
                  Total Net Balance
                </span>
                <button 
                  onClick={() => setShowBalance(!showBalance)}
                  style={{ background: 'none', border: 'none', color: '#fff', opacity: 0.8, cursor: 'pointer' }}
                >
                  {showBalance ? <Eye size={20} /> : <EyeOff size={20} />}
                </button>
              </div>

              <h2 style={{ fontSize: '40px', fontWeight: '800', marginBottom: '28px', letterSpacing: '-0.5px' }}>
                {showBalance ? `${currSymbol}${dash?.balance?.toLocaleString() || '0.00'}` : '••••••••'}
              </h2>

              <div style={{
                display: 'grid',
                gridTemplateColumns: '1fr 1fr',
                gap: '16px',
                background: 'rgba(0, 0, 0, 0.25)',
                padding: '16px 20px',
                borderRadius: '18px',
                backdropFilter: 'blur(10px)'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div style={{
                    width: '38px', height: '38px', borderRadius: '12px',
                    background: 'rgba(0, 212, 170, 0.25)', color: '#00D4AA',
                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                  }}>
                    <ArrowDownRight size={22} />
                  </div>
                  <div>
                    <span style={{ fontSize: '12px', opacity: 0.8, display: 'block' }}>Monthly Income</span>
                    <strong style={{ fontSize: '16px' }}>
                      {showBalance ? `${currSymbol}${dash?.month_income?.toLocaleString() || '0'}` : '••••'}
                    </strong>
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div style={{
                    width: '38px', height: '38px', borderRadius: '12px',
                    background: 'rgba(255, 77, 106, 0.25)', color: '#FF4D6A',
                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                  }}>
                    <ArrowUpRight size={22} />
                  </div>
                  <div>
                    <span style={{ fontSize: '12px', opacity: 0.8, display: 'block' }}>Monthly Expense</span>
                    <strong style={{ fontSize: '16px' }}>
                      {showBalance ? `${currSymbol}${dash?.month_expense?.toLocaleString() || '0'}` : '••••'}
                    </strong>
                  </div>
                </div>
              </div>
            </div>

            {/* Total Saved Card & Stats */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div className="mm-card" style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '10px' }}>
                  <div style={{
                    width: '42px', height: '42px', borderRadius: '14px',
                    background: 'rgba(0, 148, 255, 0.15)', color: 'var(--accent-blue)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                  }}>
                    <PiggyBank size={24} />
                  </div>
                  <div>
                    <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Total Wealth Saved</span>
                    <h3 style={{ fontSize: '24px', fontWeight: '700', color: 'var(--text-primary)' }}>
                      {currSymbol}{dash?.total_saved?.toLocaleString() || '0.00'}
                    </h3>
                  </div>
                </div>
                <button 
                  onClick={() => navigate('/savings')}
                  className="mm-btn-secondary"
                  style={{ width: '100%', padding: '10px', fontSize: '13px' }}
                >
                  View Savings Goals <ChevronRight size={16} />
                </button>
              </div>

              {/* Quick Actions Grid */}
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px' }}>
                {[
                  { label: 'Add Txn', icon: Plus, color: '#00D4AA', path: '/add-expense' },
                  { label: 'EMIs', icon: CreditCard, color: '#F5C842', path: '/emi' },
                  { label: 'Bills', icon: Receipt, color: '#FF4D6A', path: '/bills' },
                  { label: 'Goals', icon: Target, color: '#9B6DFF', path: '/goals' },
                ].map((act, i) => {
                  const IconC = act.icon;
                  return (
                    <div 
                      key={i}
                      onClick={() => navigate(act.path)}
                      style={{
                        background: 'var(--bg-card)',
                        border: '1px solid var(--border)',
                        borderRadius: '16px',
                        padding: '12px 6px',
                        textAlign: 'center',
                        cursor: 'pointer',
                        transition: 'all 0.2s ease'
                      }}
                      onMouseEnter={(e) => e.currentTarget.style.borderColor = act.color}
                      onMouseLeave={(e) => e.currentTarget.style.borderColor = 'var(--border)'}
                    >
                      <div style={{
                        width: '36px', height: '36px', borderRadius: '12px',
                        background: `${act.color}22`, color: act.color,
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        margin: '0 auto 6px'
                      }}>
                        <IconC size={18} />
                      </div>
                      <span style={{ fontSize: '11px', fontWeight: '600', color: 'var(--text-primary)' }}>
                        {act.label}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Main 2-Column Dashboard Grid */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))',
            gap: '24px'
          }}>
            {/* Left Column: Recent Activity & Budgets */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
              {/* Recent Activity */}
              <div className="mm-card">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '18px' }}>
                  <h3 style={{ fontSize: '17px', fontWeight: '700', color: 'var(--text-primary)' }}>
                    Recent Activity
                  </h3>
                  <button 
                    onClick={() => navigate('/transactions')}
                    style={{ background: 'none', border: 'none', color: 'var(--primary)', fontSize: '13px', fontWeight: '600', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}
                  >
                    View All <ChevronRight size={16} />
                  </button>
                </div>

                {dash?.recent_transactions?.length === 0 ? (
                  <div style={{ textAlign: 'center', padding: '30px', color: 'var(--text-muted)' }}>
                    No recent transactions. Click 'Add Transaction' to start!
                  </div>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                    {dash?.recent_transactions?.map((t) => (
                      <div key={t.id} style={{
                        padding: '12px 14px',
                        borderRadius: '14px',
                        background: 'var(--bg-elevated)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between'
                      }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                          <div style={{
                            width: '40px', height: '40px', borderRadius: '12px',
                            background: t.type === 'income' ? 'rgba(0, 212, 170, 0.15)' : 'rgba(255, 77, 106, 0.15)',
                            color: t.type === 'income' ? 'var(--primary)' : 'var(--accent-red)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center'
                          }}>
                            {t.type === 'income' ? <ArrowDownRight size={20} /> : <ArrowUpRight size={20} />}
                          </div>
                          <div>
                            <strong style={{ fontSize: '14px', color: 'var(--text-primary)', display: 'block' }}>
                              {t.category}
                            </strong>
                            <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                              {t.note || t.txn_date}
                            </span>
                          </div>
                        </div>
                        <span style={{
                          fontSize: '15px',
                          fontWeight: '700',
                          color: t.type === 'income' ? 'var(--primary)' : 'var(--text-primary)'
                        }}>
                          {t.type === 'income' ? '+' : '-'}{currSymbol}{t.amount.toLocaleString()}
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Right Column: Upcoming Bills & Category Budgets */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
              {/* Upcoming Bills Alert */}
              <div className="mm-card" style={{ borderColor: dash?.upcoming_bills?.length > 0 ? 'rgba(245, 200, 66, 0.4)' : 'var(--border)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--accent-gold)' }}>
                    <AlertCircle size={20} />
                    <h3 style={{ fontSize: '17px', fontWeight: '700', color: 'var(--text-primary)' }}>Upcoming Bills</h3>
                  </div>
                  <button 
                    onClick={() => navigate('/bills')}
                    style={{ background: 'none', border: 'none', color: 'var(--primary)', fontSize: '13px', fontWeight: '600', cursor: 'pointer' }}
                  >
                    Manage
                  </button>
                </div>

                {dash?.upcoming_bills?.length === 0 ? (
                  <p style={{ fontSize: '13px', color: 'var(--text-secondary)', textAlign: 'center', padding: '16px 0' }}>
                    No bills due in the next 7 days. All clear!
                  </p>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                    {dash?.upcoming_bills?.map((bill, i) => (
                      <div key={i} style={{
                        padding: '12px 14px', borderRadius: '12px', background: 'var(--bg-elevated)',
                        display: 'flex', justifyContent: 'space-between', alignItems: 'center'
                      }}>
                        <div>
                          <strong style={{ fontSize: '14px', display: 'block', color: 'var(--text-primary)' }}>{bill.label}</strong>
                          <span style={{ fontSize: '12px', color: 'var(--accent-gold)' }}>
                            Due in {bill.days_left} {bill.days_left === 1 ? 'day' : 'days'}
                          </span>
                        </div>
                        <span style={{ fontSize: '15px', fontWeight: '700', color: 'var(--text-primary)' }}>
                          {currSymbol}{bill.amount}
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Monthly Budgets Progress */}
              <div className="mm-card">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                  <h3 style={{ fontSize: '17px', fontWeight: '700', color: 'var(--text-primary)' }}>
                    Category Budgets
                  </h3>
                  <button 
                    onClick={() => navigate('/budget')}
                    style={{ background: 'none', border: 'none', color: 'var(--primary)', fontSize: '13px', fontWeight: '600', cursor: 'pointer' }}
                  >
                    Edit Limits
                  </button>
                </div>

                {dash?.budgets?.length === 0 ? (
                  <p style={{ fontSize: '13px', color: 'var(--text-secondary)', textAlign: 'center', padding: '16px 0' }}>
                    No budgets set for this month yet.
                  </p>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                    {dash?.budgets?.map((b, i) => {
                      const percent = Math.min(100, Math.round((b.spent / b.limit) * 100));
                      return (
                        <div key={i}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', marginBottom: '6px' }}>
                            <span style={{ fontWeight: '600', color: 'var(--text-primary)' }}>{b.category}</span>
                            <span style={{ color: 'var(--text-secondary)' }}>
                              {currSymbol}{b.spent} / {currSymbol}{b.limit}
                            </span>
                          </div>
                          <div style={{
                            height: '8px', width: '100%', borderRadius: '4px',
                            background: 'var(--bg-dark)', overflow: 'hidden'
                          }}>
                            <div style={{
                              height: '100%', width: `${percent}%`,
                              background: percent > 90 ? 'var(--accent-red)' : 'var(--primary-gradient)',
                              transition: 'width 0.3s ease'
                            }} />
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </MainLayout>
  );
}
