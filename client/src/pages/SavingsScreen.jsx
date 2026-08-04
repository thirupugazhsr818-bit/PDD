// client/src/pages/SavingsScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, PiggyBank, Trash2, CheckCircle2, X } from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function SavingsScreen() {
  const [user, setUser] = useState(null);
  const [goals, setGoals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showGoalModal, setShowGoalModal] = useState(false);
  const [showMoneyModal, setShowMoneyModal] = useState(false);
  const [selectedGoal, setSelectedGoal] = useState(null);

  const [label, setLabel] = useState('');
  const [target, setTarget] = useState('');
  const [depositAmount, setDepositAmount] = useState('');

  const navigate = useNavigate();

  useEffect(() => {
    loadGoals();
  }, []);

  const loadGoals = async () => {
    setLoading(true);
    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }
    setUser(userRes.data);

    const res = await ApiService.getSavingsGoals(userRes.data.id);
    setLoading(false);
    if (res.success) {
      setGoals(res.data);
    }
  };

  const handleAddGoal = async (e) => {
    e.preventDefault();
    if (!label || !target || parseFloat(target) <= 0) return;

    const res = await ApiService.addSavingsGoal({
      user_id: user.id,
      label,
      target: parseFloat(target)
    });

    if (res.success) {
      setShowGoalModal(false);
      setLabel('');
      setTarget('');
      loadGoals();
    }
  };

  const handleAddMoney = async (e) => {
    e.preventDefault();
    if (!depositAmount || parseFloat(depositAmount) <= 0 || !selectedGoal) return;

    const res = await ApiService.addMoneyToGoal(selectedGoal.id, parseFloat(depositAmount));
    if (res.success) {
      setShowMoneyModal(false);
      setDepositAmount('');
      setSelectedGoal(null);
      loadGoals();
    }
  };

  const handleDeleteGoal = async (id) => {
    if (!window.confirm('Delete this savings goal?')) return;
    const res = await ApiService.deleteSavingsGoal(id);
    if (res.success) loadGoals();
  };

  const totalSaved = goals.reduce((sum, g) => sum + g.saved, 0);
  const currSymbol = user?.currency === 'USD' ? '$' : user?.currency === 'EUR' ? '€' : '₹';

  return (
    <MainLayout title="Savings Wealth Tracker" user={user}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* Banner Card */}
        <div className="mm-card-gradient" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
              <PiggyBank size={22} />
              <span style={{ fontSize: '14px', opacity: 0.9 }}>Accumulated Saved Wealth</span>
            </div>
            <h2 style={{ fontSize: '36px', fontWeight: '800' }}>
              {currSymbol}{totalSaved.toLocaleString()}
            </h2>
            <span style={{ fontSize: '13px', opacity: 0.85 }}>
              Active savings targets: {goals.length}
            </span>
          </div>

          <button 
            onClick={() => setShowGoalModal(true)}
            className="mm-btn-secondary"
            style={{ width: 'auto', padding: '12px 24px', background: 'rgba(255,255,255,0.15)', color: '#fff', border: 'none' }}
          >
            <Plus size={18} /> New Savings Goal
          </button>
        </div>

        {/* Goals Grid */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
            Loading savings goals...
          </div>
        ) : goals.length === 0 ? (
          <div className="mm-card" style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
            <PiggyBank size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '18px', color: '#fff', marginBottom: '8px' }}>No Savings Goals Yet</h3>
            <p style={{ fontSize: '14px', marginBottom: '20px' }}>Start saving for an emergency fund, vacation, or new tech!</p>
            <button onClick={() => setShowGoalModal(true)} className="mm-btn-primary" style={{ width: 'auto', margin: '0 auto' }}>
              Create Target
            </button>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))',
            gap: '20px'
          }}>
            {goals.map((g) => {
              const isCompleted = g.percent >= 100;
              return (
                <div key={g.id} className="mm-card" style={{
                  borderColor: isCompleted ? 'rgba(0, 212, 170, 0.4)' : 'var(--border)',
                  display: 'flex', flexDirection: 'column', justifyContent: 'space-between'
                }}>
                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                      <strong style={{ fontSize: '17px', color: 'var(--text-primary)' }}>{g.label}</strong>
                      <button 
                        onClick={() => handleDeleteGoal(g.id)}
                        style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
                      >
                        <Trash2 size={18} />
                      </button>
                    </div>

                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '10px' }}>
                      <span>Saved: <strong style={{ color: 'var(--primary)' }}>{currSymbol}{g.saved.toLocaleString()}</strong></span>
                      <span>Target: {currSymbol}{g.target.toLocaleString()}</span>
                    </div>

                    <div style={{ height: '10px', background: 'var(--bg-dark)', borderRadius: '5px', overflow: 'hidden', marginBottom: '18px' }}>
                      <div style={{
                        height: '100%',
                        width: `${Math.min(100, g.percent)}%`,
                        background: 'var(--primary-gradient)',
                        transition: 'width 0.4s ease'
                      }} />
                    </div>
                  </div>

                  <button 
                    onClick={() => { setSelectedGoal(g); setShowMoneyModal(true); }}
                    className="mm-btn-secondary"
                    style={{ width: '100%', padding: '10px', fontSize: '13px' }}
                  >
                    <Plus size={16} /> Deposit Funds
                  </button>
                </div>
              );
            })}
          </div>
        )}

        {/* Modal: New Goal */}
        {showGoalModal && (
          <div style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(5px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 1000, padding: '20px'
          }}>
            <div className="mm-card" style={{ width: '100%', maxWidth: '440px', background: 'var(--bg-card)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>New Savings Target</h3>
                <button onClick={() => setShowGoalModal(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleAddGoal}>
                <div className="mm-input-group">
                  <label className="mm-input-label">Goal Label</label>
                  <input 
                    type="text" className="mm-input" placeholder="Emergency Fund, New Car..."
                    value={label} onChange={(e) => setLabel(e.target.value)} required
                  />
                </div>

                <div className="mm-input-group">
                  <label className="mm-input-label">Target Amount ({currSymbol})</label>
                  <input 
                    type="number" className="mm-input" placeholder="50000"
                    value={target} onChange={(e) => setTarget(e.target.value)} required
                  />
                </div>

                <button type="submit" className="mm-btn-primary" style={{ width: '100%', marginTop: '12px' }}>
                  Save Target
                </button>
              </form>
            </div>
          </div>
        )}

        {/* Modal: Deposit Money */}
        {showMoneyModal && selectedGoal && (
          <div style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(5px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 1000, padding: '20px'
          }}>
            <div className="mm-card" style={{ width: '100%', maxWidth: '440px', background: 'var(--bg-card)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Deposit to {selectedGoal.label}</h3>
                <button onClick={() => setShowMoneyModal(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleAddMoney}>
                <div className="mm-input-group">
                  <label className="mm-input-label">Deposit Amount ({currSymbol})</label>
                  <input 
                    type="number" className="mm-input" placeholder="5000"
                    value={depositAmount} onChange={(e) => setDepositAmount(e.target.value)} required autoFocus
                  />
                </div>

                <button type="submit" className="mm-btn-primary" style={{ width: '100%', marginTop: '12px' }}>
                  Confirm Deposit
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
