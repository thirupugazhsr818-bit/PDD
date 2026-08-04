// client/src/pages/EmiScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, CreditCard, CheckCircle2, Trash2, Landmark, X } from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function EmiScreen() {
  const [user, setUser] = useState(null);
  const [emis, setEmis] = useState([]);
  const [status, setStatus] = useState('active');
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const [label, setLabel] = useState('');
  const [bank, setBank] = useState('');
  const [emiAmount, setEmiAmount] = useState('');
  const [totalMonths, setTotalMonths] = useState('');
  const [dueDay, setDueDay] = useState('5');

  const navigate = useNavigate();

  useEffect(() => {
    loadEmis();
  }, [status]);

  const loadEmis = async () => {
    setLoading(true);
    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }
    setUser(userRes.data);

    const res = await ApiService.getEmis(userRes.data.id, status);
    setLoading(false);
    if (res.success) {
      setEmis(res.data);
    }
  };

  const handleAddEmi = async (e) => {
    e.preventDefault();
    if (!label || !emiAmount || !totalMonths || !dueDay) return;

    const res = await ApiService.addEmi({
      user_id: user.id,
      label,
      bank,
      emi_amount: parseFloat(emiAmount),
      total_months: parseInt(totalMonths),
      due_day: parseInt(dueDay)
    });

    if (res.success) {
      setShowModal(false);
      setLabel('');
      setBank('');
      setEmiAmount('');
      setTotalMonths('');
      loadEmis();
    }
  };

  const handleMarkPaid = async (emiId) => {
    const res = await ApiService.markEmiPaid(emiId);
    if (res.success) loadEmis();
  };

  const handleDeleteEmi = async (emiId) => {
    if (!window.confirm('Delete this EMI entry?')) return;
    const res = await ApiService.deleteEmi(emiId);
    if (res.success) loadEmis();
  };

  const totalOutstanding = emis.reduce((sum, e) => sum + e.outstanding, 0);
  const currSymbol = user?.currency === 'USD' ? '$' : user?.currency === 'EUR' ? '€' : '₹';

  return (
    <MainLayout title="EMI Loan Manager" user={user}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* Banner Card */}
        <div className="mm-card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: 'linear-gradient(135deg, #1A2234 0%, #111827 100%)', border: '1px solid var(--border)' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--accent-gold)', marginBottom: '6px' }}>
              <CreditCard size={20} />
              <span style={{ fontSize: '14px', fontWeight: '600' }}>Active Loan Outstanding Balance</span>
            </div>

            <h2 style={{ fontSize: '36px', fontWeight: '800', color: '#fff' }}>
              {currSymbol}{totalOutstanding.toLocaleString()}
            </h2>

            <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
              Outstanding balance across {emis.length} {status} EMI loans
            </span>
          </div>

          <button 
            onClick={() => setShowModal(true)}
            className="mm-btn-primary"
            style={{ width: 'auto', padding: '12px 24px' }}
          >
            <Plus size={18} /> Add Loan EMI
          </button>
        </div>

        {/* Status Filter */}
        <div style={{ display: 'flex', gap: '12px' }}>
          {['active', 'closed'].map(st => (
            <button
              key={st}
              onClick={() => setStatus(st)}
              style={{
                padding: '10px 24px',
                borderRadius: '12px',
                border: '1px solid var(--border)',
                background: status === st ? 'var(--bg-elevated)' : 'var(--bg-card)',
                color: status === st ? 'var(--primary)' : 'var(--text-secondary)',
                fontWeight: '700',
                cursor: 'pointer',
                textTransform: 'capitalize'
              }}
            >
              {st} Loans
            </button>
          ))}
        </div>

        {/* EMI Cards Grid */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
            Loading EMI details...
          </div>
        ) : emis.length === 0 ? (
          <div className="mm-card" style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
            <CreditCard size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '18px', color: '#fff', marginBottom: '8px' }}>No {status} EMI loans found</h3>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))',
            gap: '20px'
          }}>
            {emis.map((e) => (
              <div key={e.id} className="mm-card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                    <div>
                      <strong style={{ fontSize: '17px', color: 'var(--text-primary)', display: 'block' }}>{e.label}</strong>
                      <span style={{ fontSize: '13px', color: 'var(--accent-blue)', display: 'flex', alignItems: 'center', gap: '4px' }}>
                        <Landmark size={14} /> {e.bank || 'Personal Loan'}
                      </span>
                    </div>
                    <button 
                      onClick={() => handleDeleteEmi(e.id)}
                      style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
                    >
                      <Trash2 size={18} />
                    </button>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', fontSize: '14px', marginBottom: '16px' }}>
                    <div>
                      <span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '12px' }}>Monthly Installment</span>
                      <strong style={{ color: 'var(--text-primary)' }}>{currSymbol}{e.emi_amount.toLocaleString()}</strong>
                    </div>
                    <div>
                      <span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '12px' }}>Paid Months</span>
                      <strong style={{ color: 'var(--primary)' }}>{e.paid_months} / {e.total_months}</strong>
                    </div>
                  </div>

                  <div style={{ height: '8px', background: 'var(--bg-dark)', borderRadius: '4px', overflow: 'hidden', marginBottom: '16px' }}>
                    <div style={{
                      height: '100%',
                      width: `${e.percent_paid}%`,
                      background: 'var(--primary-gradient)',
                      transition: 'width 0.3s ease'
                    }} />
                  </div>
                </div>

                {status === 'active' && (
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '13px', color: 'var(--accent-gold)' }}>
                      Due Day: {e.due_day}th of month
                    </span>
                    <button 
                      onClick={() => handleMarkPaid(e.id)}
                      className="mm-btn-secondary"
                      style={{ width: 'auto', padding: '8px 16px', fontSize: '13px' }}
                    >
                      <CheckCircle2 size={16} color="var(--primary)" /> Pay EMI Month
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* Modal: Add EMI */}
        {showModal && (
          <div style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(5px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 1000, padding: '20px'
          }}>
            <div className="mm-card" style={{ width: '100%', maxWidth: '440px', background: 'var(--bg-card)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Add Loan EMI</h3>
                <button onClick={() => setShowModal(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleAddEmi}>
                <div className="mm-input-group">
                  <label className="mm-input-label">Loan Name / Description</label>
                  <input type="text" className="mm-input" placeholder="Home Loan, Laptop EMI..." value={label} onChange={(e) => setLabel(e.target.value)} required />
                </div>
                <div className="mm-input-group">
                  <label className="mm-input-label">Bank Name</label>
                  <input type="text" className="mm-input" placeholder="HDFC, SBI, ICICI..." value={bank} onChange={(e) => setBank(e.target.value)} />
                </div>
                <div className="mm-input-group">
                  <label className="mm-input-label">Monthly Installment ({currSymbol})</label>
                  <input type="number" className="mm-input" placeholder="15000" value={emiAmount} onChange={(e) => setEmiAmount(e.target.value)} required />
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div className="mm-input-group">
                    <label className="mm-input-label">Total Months</label>
                    <input type="number" className="mm-input" placeholder="24" value={totalMonths} onChange={(e) => setTotalMonths(e.target.value)} required />
                  </div>
                  <div className="mm-input-group">
                    <label className="mm-input-label">Due Day</label>
                    <input type="number" min="1" max="31" className="mm-input" value={dueDay} onChange={(e) => setDueDay(e.target.value)} required />
                  </div>
                </div>

                <button type="submit" className="mm-btn-primary" style={{ width: '100%', marginTop: '12px' }}>
                  Save Loan EMI
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
