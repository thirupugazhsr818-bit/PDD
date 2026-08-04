// client/src/pages/SplashScreen.jsx
import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Wallet, Sparkles } from 'lucide-react';
import { ApiService } from '../services/api';

export default function SplashScreen() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(async () => {
      const res = await ApiService.getCurrentUser();
      if (res.success && res.data) {
        navigate('/home');
      } else {
        navigate('/onboarding');
      }
    }, 2000);

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'var(--bg-gradient)',
      padding: '24px',
      textAlign: 'center'
    }}>
      <div className="pulse-glow" style={{
        width: '100px',
        height: '100px',
        borderRadius: '30px',
        background: 'var(--primary-gradient)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#fff',
        marginBottom: '28px',
        position: 'relative'
      }}>
        <Wallet size={52} />
      </div>

      <h1 style={{
        fontSize: '32px',
        fontWeight: '800',
        color: '#fff',
        letterSpacing: '-0.5px',
        marginBottom: '8px'
      }}>
        Money<span style={{ color: 'var(--primary)' }}>Mate</span>
      </h1>

      <p style={{
        fontSize: '15px',
        color: 'var(--text-secondary)',
        maxWidth: '280px',
        marginBottom: '40px'
      }}>
        Master Your Finances & Build Wealth Effortlessly
      </p>

      <div style={{
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        background: 'rgba(0, 212, 170, 0.1)',
        padding: '8px 16px',
        borderRadius: '20px',
        border: '1px solid rgba(0, 212, 170, 0.3)',
        color: 'var(--primary)',
        fontSize: '13px',
        fontWeight: '600'
      }}>
        <Sparkles size={16} />
        Smart Financial Suite
      </div>
    </div>
  );
}
