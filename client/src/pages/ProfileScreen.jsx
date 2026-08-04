// client/src/pages/ProfileScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, Phone, Globe, LogOut, Edit2, ShieldCheck, X } from 'lucide-react';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

export default function ProfileScreen() {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showEditModal, setShowEditModal] = useState(false);

  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [currency, setCurrency] = useState('INR');

  const navigate = useNavigate();

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    setLoading(true);
    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }

    const profRes = await ApiService.getProfile(userRes.data.id);
    setLoading(false);
    if (profRes.success) {
      setProfile(profRes.data);
      setName(profRes.data.name);
      setPhone(profRes.data.phone);
      setCurrency(profRes.data.currency || 'INR');
    }
  };

  const handleUpdate = async (e) => {
    e.preventDefault();
    if (!profile) return;

    const res = await ApiService.updateProfile(profile.id, { name, phone, currency });
    if (res.success) {
      setShowEditModal(false);
      loadProfile();
    }
  };

  const handleLogout = async () => {
    if (profile) {
      await ApiService.logout(profile.email);
    }
    navigate('/login');
  };

  return (
    <MainLayout title="User Profile & Settings" user={profile}>
      <div style={{ maxWidth: '800px', margin: '0 auto', display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
            Loading profile...
          </div>
        ) : profile ? (
          <>
            {/* Header Avatar Box */}
            <div className="mm-card" style={{ display: 'flex', alignItems: 'center', gap: '24px', padding: '32px' }}>
              <div style={{
                width: '90px', height: '90px', borderRadius: '50%',
                background: 'var(--primary-gradient)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: '36px', fontWeight: '800', color: '#fff',
                boxShadow: '0 10px 25px rgba(0, 212, 170, 0.4)',
                flexShrink: 0
              }}>
                {profile.name ? profile.name.charAt(0).toUpperCase() : 'U'}
              </div>

              <div style={{ flex: 1 }}>
                <h2 style={{ fontSize: '24px', fontWeight: '700', color: 'var(--text-primary)', marginBottom: '4px' }}>
                  {profile.name}
                </h2>
                <span style={{ fontSize: '14px', color: 'var(--text-secondary)', display: 'block', marginBottom: '16px' }}>
                  {profile.email}
                </span>

                <button 
                  onClick={() => setShowEditModal(true)}
                  className="mm-btn-secondary"
                  style={{ width: 'auto', padding: '10px 20px', fontSize: '13px' }}
                >
                  <Edit2 size={16} /> Edit Profile Info
                </button>
              </div>
            </div>

            {/* Account Settings List */}
            <div className="mm-card">
              <h3 style={{ fontSize: '17px', fontWeight: '700', color: '#fff', marginBottom: '20px' }}>
                Account & Preferences
              </h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                  <Phone size={20} color="var(--primary)" />
                  <div>
                    <span style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block' }}>Phone Number</span>
                    <strong style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{profile.phone}</strong>
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '16px', borderTop: '1px solid var(--border)', paddingTop: '16px' }}>
                  <Globe size={20} color="var(--accent-blue)" />
                  <div>
                    <span style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block' }}>Default Wallet Currency</span>
                    <strong style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{profile.currency}</strong>
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '16px', borderTop: '1px solid var(--border)', paddingTop: '16px' }}>
                  <ShieldCheck size={20} color="var(--accent-gold)" />
                  <div>
                    <span style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block' }}>Registration Date</span>
                    <strong style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{profile.created_at || 'Recently'}</strong>
                  </div>
                </div>
              </div>
            </div>

            {/* Logout Action */}
            <button 
              onClick={handleLogout}
              className="mm-btn-secondary"
              style={{
                borderColor: 'rgba(255, 77, 106, 0.4)',
                color: 'var(--accent-red)',
                padding: '14px'
              }}
            >
              <LogOut size={18} /> Sign Out of MoneyMate
            </button>
          </>
        ) : null}

        {/* Modal: Edit Profile */}
        {showEditModal && (
          <div style={{
            position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
            background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(5px)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            zIndex: 1000, padding: '20px'
          }}>
            <div className="mm-card" style={{ width: '100%', maxWidth: '440px', background: 'var(--bg-card)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Edit Profile Information</h3>
                <button onClick={() => setShowEditModal(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleUpdate}>
                <div className="mm-input-group">
                  <label className="mm-input-label">Full Name</label>
                  <input type="text" className="mm-input" value={name} onChange={(e) => setName(e.target.value)} required />
                </div>

                <div className="mm-input-group">
                  <label className="mm-input-label">Phone Number</label>
                  <input type="text" className="mm-input" value={phone} onChange={(e) => setPhone(e.target.value)} required />
                </div>

                <div className="mm-input-group">
                  <label className="mm-input-label">Preferred Currency</label>
                  <select className="mm-input" value={currency} onChange={(e) => setCurrency(e.target.value)}>
                    <option value="INR" style={{ background: '#111827' }}>INR (₹)</option>
                    <option value="USD" style={{ background: '#111827' }}>USD ($)</option>
                    <option value="EUR" style={{ background: '#111827' }}>EUR (€)</option>
                    <option value="GBP" style={{ background: '#111827' }}>GBP (£)</option>
                  </select>
                </div>

                <button type="submit" className="mm-btn-primary" style={{ width: '100%', marginTop: '12px' }}>
                  Update Details
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
