// client/src/pages/BillsScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Receipt, CheckCircle, Trash2, X } from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function BillsScreen() {
  const [user, setUser] = useState(null);
  const [bills, setBills] = useState([]);
  const [filterPaid, setFilterPaid] = useState(0);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const [label, setLabel] = useState('');
  const [amount, setAmount] = useState('');
  const [dueDay, setDueDay] = useState('10');

  const navigate = useNavigate();

  useEffect(() => {
    loadBills();
  }, [filterPaid]);

  const loadBills = async () => {
    setLoading(true);
    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }
    setUser(userRes.data);

    const res = await ApiService.getBills(userRes.data.id, filterPaid);
    setLoading(false);
    if (res.success) {
      setBills(res.data);
    }
  };

  const handleAddBill = async (e) => {
    e.preventDefault();
    if (!label || !amount || !dueDay) return;

    const res = await ApiService.addBill({
      user_id: user.id,
      label,
      amount: parseFloat(amount),
      due_day: parseInt(dueDay)
    });

    if (res.success) {
      setShowModal(false);
      setLabel('');
      setAmount('');
      loadBills();
    }
  };

  const handleTogglePaid = async (bill) => {
    if (bill.is_paid) {
      await ApiService.markBillUnpaid(bill.id);
    } else {
      await ApiService.markBillPaid(bill.id);
    }
    loadBills();
  };

  const handleDeleteBill = async (billId) => {
    if (!window.confirm('Delete this bill reminder?')) return;
    const res = await ApiService.deleteBill(billId);
    if (res.success) loadBills();
  };

  const currSymbol = user?.currency === 'USD' ? '$' : user?.currency === 'EUR' ? '€' : '₹';

  return (
    <MainLayout title="Bills & Utility Reminders" user={user}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* Banner */}
        <div className="mm-card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h3 style={{ fontSize: '20px', fontWeight: '700', color: '#fff', marginBottom: '4px' }}>
              Monthly Utility & Subscription Bills
            </h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
              Set due day reminders so you never pay late fees again.
            </p>
          </div>

          <button 
            onClick={() => setShowModal(true)}
            className="mm-btn-primary"
            style={{ width: 'auto', padding: '12px 24px' }}
          >
            <Plus size={18} /> Add New Bill
          </button>
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: '12px' }}>
          <button 
            onClick={() => setFilterPaid(0)}
            style={{
              padding: '10px 24px',
              borderRadius: '12px',
              border: '1px solid var(--border)',
              background: filterPaid === 0 ? 'var(--bg-elevated)' : 'var(--bg-card)',
              color: filterPaid === 0 ? 'var(--accent-gold)' : 'var(--text-secondary)',
              fontWeight: '700',
              cursor: 'pointer'
            }}
          >
            Pending Bills
          </button>
          <button 
            onClick={() => setFilterPaid(1)}
            style={{
              padding: '10px 24px',
              borderRadius: '12px',
              border: '1px solid var(--border)',
              background: filterPaid === 1 ? 'var(--bg-elevated)' : 'var(--bg-card)',
              color: filterPaid === 1 ? 'var(--primary)' : 'var(--text-secondary)',
              fontWeight: '700',
              cursor: 'pointer'
            }}
          >
            Paid History
          </button>
        </div>

        {/* Bills Grid */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
            Loading bill reminders...
          </div>
        ) : bills.length === 0 ? (
          <div className="mm-card" style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
            <Receipt size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '18px', color: '#fff', marginBottom: '8px' }}>No {filterPaid === 0 ? 'pending' : 'paid'} bills</h3>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))',
            gap: '20px'
          }}>
            {bills.map((b) => (
              <div key={b.id} className="mm-card" style={{
                display: 'flex', alignItems: 'center', justifyContent: 'space-between'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                  <div style={{
                    width: '46px', height: '46px', borderRadius: '14px',
                    background: b.is_paid ? 'rgba(0, 212, 170, 0.15)' : 'rgba(245, 200, 66, 0.15)',
                    color: b.is_paid ? 'var(--primary)' : 'var(--accent-gold)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                  }}>
                    <Receipt size={24} />
                  </div>
                  <div>
                    <strong style={{ fontSize: '16px', color: 'var(--text-primary)', display: 'block' }}>{b.label}</strong>
                    <span style={{ fontSize: '13px', color: b.is_paid ? 'var(--primary)' : 'var(--accent-gold)' }}>
                      {b.is_paid ? 'Paid' : `Due in ${b.days_left} days (${b.due_day}th)`}
                    </span>
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                  <span style={{ fontSize: '18px', fontWeight: '700', color: 'var(--text-primary)' }}>
                    {currSymbol}{b.amount.toLocaleString()}
                  </span>

                  <button 
                    onClick={() => handleTogglePaid(b)}
                    style={{
                      background: b.is_paid ? 'rgba(0,212,170,0.2)' : 'var(--bg-elevated)',
                      border: '1px solid var(--border)',
                      borderRadius: '12px',
                      padding: '10px',
                      color: b.is_paid ? 'var(--primary)' : 'var(--text-secondary)',
                      cursor: 'pointer'
                    }}
                  >
                    <CheckCircle size={20} />
                  </button>

                  <button 
                    onClick={() => handleDeleteBill(b.id)}
                    style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Modal: Add Bill */}
        {showModal && (
          <div style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(5px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 1000, padding: '20px'
          }}>
            <div className="mm-card" style={{ width: '100%', maxWidth: '440px', background: 'var(--bg-card)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>New Bill Reminder</h3>
                <button onClick={() => setShowModal(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleAddBill}>
                <div className="mm-input-group">
                  <label className="mm-input-label">Bill Name / Label</label>
                  <input type="text" className="mm-input" placeholder="Electricity Bill, Wi-Fi..." value={label} onChange={(e) => setLabel(e.target.value)} required />
                </div>
                <div className="mm-input-group">
                  <label className="mm-input-label">Amount ({currSymbol})</label>
                  <input type="number" className="mm-input" placeholder="1200" value={amount} onChange={(e) => setAmount(e.target.value)} required />
                </div>
                <div className="mm-input-group">
                  <label className="mm-input-label">Due Day of Month</label>
                  <input type="number" min="1" max="31" className="mm-input" value={dueDay} onChange={(e) => setDueDay(e.target.value)} required />
                </div>

                <button type="submit" className="mm-btn-primary" style={{ width: '100%', marginTop: '12px' }}>
                  Save Reminder
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
