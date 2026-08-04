// client/src/components/Header.jsx
import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Menu, Wallet } from 'lucide-react';

export default function Header({ title, showBack = false, user, onToggleSidebar, isSidebarOpen }) {
  const navigate = useNavigate();

  return (
    <header style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '20px 32px',
      background: 'var(--bg-dark)',
      borderBottom: '1px solid var(--border)',
      position: 'sticky',
      top: 0,
      zIndex: 90
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        {/* Hamburger Menu Toggle Button */}
        <button
          onClick={onToggleSidebar}
          title="Toggle Navigation Menu"
          style={{
            background: isSidebarOpen ? 'rgba(0, 212, 170, 0.15)' : 'var(--bg-elevated)',
            border: isSidebarOpen ? '1px solid rgba(0, 212, 170, 0.3)' : '1px solid var(--border)',
            borderRadius: '12px',
            width: '42px',
            height: '42px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: isSidebarOpen ? 'var(--primary)' : 'var(--text-primary)',
            cursor: 'pointer',
            transition: 'all 0.2s ease'
          }}
        >
          <Menu size={22} />
        </button>

        {showBack && (
          <button 
            onClick={() => navigate(-1)}
            style={{
              background: 'var(--bg-elevated)',
              border: '1px solid var(--border)',
              borderRadius: '12px',
              width: '40px',
              height: '40px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--text-primary)',
              cursor: 'pointer'
            }}
          >
            <ArrowLeft size={20} />
          </button>
        )}

        <div>
          <h2 style={{ fontSize: '22px', fontWeight: '700', color: 'var(--text-primary)', margin: 0 }}>
            {title || 'Dashboard'}
          </h2>
          <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
            MoneyMate Financial Overview
          </span>
        </div>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        {user && (
          <div 
            onClick={() => navigate('/profile')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              cursor: 'pointer',
              background: 'var(--bg-card)',
              padding: '8px 16px',
              borderRadius: '24px',
              border: '1px solid var(--border)'
            }}
          >
            <div style={{
              width: '32px',
              height: '32px',
              borderRadius: '50%',
              background: 'var(--primary-gradient)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '13px',
              fontWeight: '700',
              color: '#fff'
            }}>
              {user.name ? user.name.charAt(0).toUpperCase() : 'U'}
            </div>
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              <span style={{ fontSize: '14px', fontWeight: '600', color: 'var(--text-primary)' }}>
                {user.name || 'User'}
              </span>
              <span style={{ fontSize: '11px', color: 'var(--primary)' }}>
                {user.currency || 'INR'}
              </span>
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
