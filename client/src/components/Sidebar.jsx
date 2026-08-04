// client/src/components/Sidebar.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  Home, PieChart, PlusCircle, Wallet, PiggyBank, 
  CreditCard, Receipt, Target, List, User, LogOut, X 
} from 'lucide-react';
import { ApiService } from '../services/api';

export default function Sidebar({ isOpen, onClose }) {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    ApiService.getCurrentUser().then(res => {
      if (res.success) setUser(res.data);
    });
  }, []);

  const navItems = [
    { path: '/home', label: 'Dashboard', icon: Home },
    { path: '/spending-chart', label: 'Analytics', icon: PieChart },
    { path: '/add-expense', label: 'Add Transaction', icon: PlusCircle, isHighlight: true },
    { path: '/budget', label: 'Monthly Budget', icon: Wallet },
    { path: '/savings', label: 'Savings Goals', icon: PiggyBank },
    { path: '/emi', label: 'EMI Tracker', icon: CreditCard },
    { path: '/bills', label: 'Bills & Reminders', icon: Receipt },
    { path: '/goals', label: 'Milestone Goals', icon: Target },
    { path: '/transactions', label: 'All History', icon: List },
    { path: '/profile', label: 'Profile Settings', icon: User },
  ];

  const handleLogout = async () => {
    if (user) await ApiService.logout(user.email);
    navigate('/login');
  };

  return (
    <>
      {/* Mobile Backdrop overlay */}
      {isOpen && (
        <div 
          onClick={onClose}
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0, 0, 0, 0.6)',
            backdropFilter: 'blur(4px)',
            zIndex: 190,
            display: window.innerWidth < 1024 ? 'block' : 'none'
          }}
        />
      )}

      <aside style={{
        width: '270px',
        background: 'var(--bg-sidebar)',
        borderRight: '1px solid var(--border)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        padding: '24px 18px',
        position: 'fixed',
        top: 0,
        bottom: 0,
        left: isOpen ? 0 : '-270px',
        height: '100vh',
        zIndex: 200,
        transition: 'left 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        boxShadow: isOpen ? '10px 0 30px rgba(0,0,0,0.5)' : 'none'
      }}>
        <div>
          {/* Header & Logo */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '4px 8px 24px 8px',
            borderBottom: '1px solid var(--border)',
            marginBottom: '20px'
          }}>
            <div 
              onClick={() => { navigate('/home'); if(window.innerWidth < 1024) onClose(); }}
              style={{ display: 'flex', alignItems: 'center', gap: '12px', cursor: 'pointer' }}
            >
              <div style={{
                width: '42px',
                height: '42px',
                borderRadius: '14px',
                background: 'var(--primary-gradient)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#fff',
                boxShadow: '0 6px 18px rgba(0, 212, 170, 0.35)'
              }}>
                <Wallet size={24} />
              </div>
              <div>
                <h1 style={{ fontSize: '18px', fontWeight: '800', color: '#fff', margin: 0, letterSpacing: '-0.3px' }}>
                  Money<span style={{ color: 'var(--primary)' }}>Mate</span>
                </h1>
                <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Finance Manager</span>
              </div>
            </div>

            {/* Close button for hamburger menu */}
            <button 
              onClick={onClose}
              style={{
                background: 'var(--bg-elevated)',
                border: '1px solid var(--border)',
                borderRadius: '10px',
                width: '34px',
                height: '34px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'var(--text-muted)',
                cursor: 'pointer'
              }}
            >
              <X size={18} />
            </button>
          </div>

          {/* Navigation Menu */}
          <nav style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            {navItems.map((item, idx) => {
              const isActive = location.pathname === item.path;
              const IconComp = item.icon;

              if (item.isHighlight) {
                return (
                  <button
                    key={idx}
                    onClick={() => { navigate(item.path); if(window.innerWidth < 1024) onClose(); }}
                    className="mm-btn-primary"
                    style={{
                      margin: '10px 0',
                      padding: '12px 16px',
                      fontSize: '14px',
                      justifyContent: 'flex-start',
                      gap: '12px',
                      borderRadius: '14px'
                    }}
                  >
                    <IconComp size={20} />
                    <span>{item.label}</span>
                  </button>
                );
              }

              return (
                <button
                  key={idx}
                  onClick={() => { navigate(item.path); if(window.innerWidth < 1024) onClose(); }}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 16px',
                    borderRadius: '12px',
                    border: 'none',
                    background: isActive ? 'var(--bg-elevated)' : 'transparent',
                    color: isActive ? 'var(--primary)' : 'var(--text-secondary)',
                    fontSize: '14px',
                    fontWeight: isActive ? '700' : '500',
                    cursor: 'pointer',
                    textAlign: 'left',
                    transition: 'all 0.2s ease'
                  }}
                >
                  <IconComp size={18} color={isActive ? 'var(--primary)' : 'var(--text-muted)'} />
                  <span>{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>

        {/* User Profile Summary */}
        {user && (
          <div style={{
            borderTop: '1px solid var(--border)',
            paddingTop: '16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between'
          }}>
            <div 
              onClick={() => { navigate('/profile'); if(window.innerWidth < 1024) onClose(); }}
              style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}
            >
              <div style={{
                width: '36px', height: '36px', borderRadius: '50%',
                background: 'var(--primary-gradient)', display: 'flex',
                alignItems: 'center', justifyContent: 'center', fontWeight: '700',
                color: '#fff', fontSize: '14px'
              }}>
                {user.name ? user.name.charAt(0).toUpperCase() : 'U'}
              </div>
              <div>
                <strong style={{ fontSize: '13px', color: '#fff', display: 'block' }}>
                  {user.name ? user.name.split(' ')[0] : 'User'}
                </strong>
                <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                  {user.currency || 'INR'} Wallet
                </span>
              </div>
            </div>

            <button 
              onClick={handleLogout}
              title="Log out"
              style={{
                background: 'none',
                border: 'none',
                color: 'var(--text-muted)',
                cursor: 'pointer',
                padding: '6px',
                borderRadius: '8px'
              }}
            >
              <LogOut size={18} />
            </button>
          </div>
        )}
      </aside>
    </>
  );
}
