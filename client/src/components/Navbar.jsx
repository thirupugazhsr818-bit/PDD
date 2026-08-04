// client/src/components/Navbar.jsx
import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Home, PieChart, Plus, Wallet, User } from 'lucide-react';

export default function Navbar() {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { path: '/home', label: 'Home', icon: Home },
    { path: '/spending-chart', label: 'Analytics', icon: PieChart },
    { path: '/add-expense', label: '', icon: Plus, isCenter: true },
    { path: '/budget', label: 'Budget', icon: Wallet },
    { path: '/profile', label: 'Profile', icon: User },
  ];

  return (
    <nav style={{
      position: 'sticky',
      bottom: 0,
      left: 0,
      right: 0,
      backgroundColor: 'var(--bg-card)',
      borderTop: '1px solid var(--border)',
      boxShadow: '0 -5px 25px rgba(0,0,0,0.5)',
      zIndex: 100,
      padding: '8px 12px 12px 12px'
    }}>
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        position: 'relative'
      }}>
        {navItems.map((item, index) => {
          if (item.isCenter) {
            return (
              <div 
                key={index}
                onClick={() => navigate(item.path)}
                style={{
                  position: 'relative',
                  top: '-20px',
                  width: '56px',
                  height: '56px',
                  borderRadius: '50%',
                  background: 'var(--primary-gradient)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#fff',
                  boxShadow: '0 8px 20px rgba(0, 212, 170, 0.45)',
                  cursor: 'pointer',
                  transition: 'transform 0.2s ease',
                }}
                onMouseEnter={(e) => e.currentTarget.style.transform = 'scale(1.08)'}
                onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}
              >
                <Plus size={28} strokeWidth={2.5} />
              </div>
            );
          }

          const isActive = location.pathname === item.path;
          const IconComp = item.icon;

          return (
            <button
              key={index}
              onClick={() => navigate(item.path)}
              style={{
                background: 'none',
                border: 'none',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '4px',
                color: isActive ? 'var(--primary)' : 'var(--text-muted)',
                cursor: 'pointer',
                padding: '6px 12px',
                transition: 'color 0.2s ease'
              }}
            >
              <IconComp size={22} strokeWidth={isActive ? 2.5 : 1.8} />
              <span style={{
                fontSize: '11px',
                fontWeight: isActive ? '700' : '400',
              }}>
                {item.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
