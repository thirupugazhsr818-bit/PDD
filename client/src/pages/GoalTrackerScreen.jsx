// client/src/pages/GoalTrackerScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Target, CheckSquare, Square, Trash2, X } from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function GoalTrackerScreen() {
  const [user, setUser] = useState(null);
  const [goals, setGoals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const [label, setLabel] = useState('');
  const [milestonesText, setMilestonesText] = useState('');

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

    const res = await ApiService.getGoals(userRes.data.id);
    setLoading(false);
    if (res.success) {
      setGoals(res.data);
    }
  };

  const handleAddGoal = async (e) => {
    e.preventDefault();
    if (!label) return;

    const milestones = milestonesText
      .split('\n')
      .map(m => m.trim())
      .filter(m => m.length > 0)
      .map(m => ({ title: m, done: false }));

    const res = await ApiService.addGoal({
      user_id: user.id,
      label,
      progress: 0,
      milestones
    });

    if (res.success) {
      setShowModal(false);
      setLabel('');
      setMilestonesText('');
      loadGoals();
    }
  };

  const handleToggleMilestone = async (goal, index) => {
    const updatedMilestones = [...(goal.milestones || [])];
    if (typeof updatedMilestones[index] === 'string') {
      updatedMilestones[index] = { title: updatedMilestones[index], done: true };
    } else {
      updatedMilestones[index] = {
        ...updatedMilestones[index],
        done: !updatedMilestones[index].done
      };
    }

    const doneCount = updatedMilestones.filter(m => typeof m === 'object' && m.done).length;
    const progress = updatedMilestones.length > 0 ? (doneCount / updatedMilestones.length) * 100 : 0;

    const res = await ApiService.updateGoal(goal.id, {
      progress: Math.round(progress),
      milestones: updatedMilestones
    });

    if (res.success) loadGoals();
  };

  const handleDeleteGoal = async (id) => {
    if (!window.confirm('Delete this milestone goal?')) return;
    const res = await ApiService.deleteGoal(id);
    if (res.success) loadGoals();
  };

  return (
    <MainLayout title="Milestone & Life Goals Tracker" user={user}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* Banner */}
        <div className="mm-card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h3 style={{ fontSize: '20px', fontWeight: '700', color: '#fff', marginBottom: '4px' }}>
              Track Financial & Life Goals
            </h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
              Break down big financial ambitions into manageable milestone checklists.
            </p>
          </div>

          <button 
            onClick={() => setShowModal(true)}
            className="mm-btn-primary"
            style={{ width: 'auto', padding: '12px 24px' }}
          >
            <Plus size={18} /> New Milestone Goal
          </button>
        </div>

        {/* Goals Grid */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
            Loading goals...
          </div>
        ) : goals.length === 0 ? (
          <div className="mm-card" style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
            <Target size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3 style={{ fontSize: '18px', color: '#fff', marginBottom: '8px' }}>No Milestone Goals Created</h3>
            <p style={{ fontSize: '14px', marginBottom: '20px' }}>Add life goals like Buy a House, Launch Startup, Travel...</p>
            <button onClick={() => setShowModal(true)} className="mm-btn-primary" style={{ width: 'auto', margin: '0 auto' }}>
              Create First Goal
            </button>
          </div>
        ) : (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))',
            gap: '20px'
          }}>
            {goals.map((g) => {
              const ms = g.milestones || [];
              return (
                <div key={g.id} className="mm-card">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                    <strong style={{ fontSize: '18px', color: 'var(--text-primary)' }}>{g.label}</strong>
                    <button 
                      onClick={() => handleDeleteGoal(g.id)}
                      style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
                    >
                      <Trash2 size={18} />
                    </button>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
                    <span>Progress</span>
                    <span>{Math.round(g.progress)}%</span>
                  </div>

                  <div style={{ height: '8px', background: 'var(--bg-dark)', borderRadius: '4px', overflow: 'hidden', marginBottom: '18px' }}>
                    <div style={{
                      height: '100%',
                      width: `${Math.min(100, g.progress)}%`,
                      background: 'var(--primary-gradient)',
                      transition: 'width 0.4s ease'
                    }} />
                  </div>

                  {/* Milestones Checklist */}
                  {ms.length > 0 && (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', borderTop: '1px solid var(--border)', paddingTop: '14px' }}>
                      <span style={{ fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)' }}>Milestone Tasks</span>
                      {ms.map((m, idx) => {
                        const isDone = typeof m === 'object' ? m.done : false;
                        const titleText = typeof m === 'object' ? m.title : m;

                        return (
                          <div 
                            key={idx}
                            onClick={() => handleToggleMilestone(g, idx)}
                            style={{
                              display: 'flex', alignItems: 'center', gap: '10px',
                              fontSize: '14px', cursor: 'pointer',
                              color: isDone ? 'var(--primary)' : 'var(--text-primary)',
                              textDecoration: isDone ? 'line-through' : 'none'
                            }}
                          >
                            {isDone ? <CheckSquare size={18} color="var(--primary)" /> : <Square size={18} color="var(--text-muted)" />}
                            {titleText}
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}

        {/* Modal: Add Goal */}
        {showModal && (
          <div style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(5px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 1000, padding: '20px'
          }}>
            <div className="mm-card" style={{ width: '100%', maxWidth: '440px', background: 'var(--bg-card)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>New Milestone Goal</h3>
                <button onClick={() => setShowModal(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleAddGoal}>
                <div className="mm-input-group">
                  <label className="mm-input-label">Goal Title</label>
                  <input type="text" className="mm-input" placeholder="Buy First Home, Launch Startup..." value={label} onChange={(e) => setLabel(e.target.value)} required />
                </div>

                <div className="mm-input-group">
                  <label className="mm-input-label">Milestone Tasks (One per line)</label>
                  <textarea 
                    className="mm-input" 
                    rows={4}
                    placeholder="Save down payment&#10;Research locations&#10;Finalize purchase"
                    value={milestonesText}
                    onChange={(e) => setMilestonesText(e.target.value)}
                  />
                </div>

                <button type="submit" className="mm-btn-primary" style={{ width: '100%', marginTop: '12px' }}>
                  Save Milestone Goal
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
