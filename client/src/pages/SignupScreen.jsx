// client/src/pages/SignupScreen.jsx
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { User, Mail, Phone, Lock, UserPlus, Wallet, AlertCircle } from 'lucide-react';
import { ApiService } from '../services/api';

export default function SignupScreen() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [currency, setCurrency] = useState('INR');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const navigate = useNavigate();

  const handleSignup = async (e) => {
    e.preventDefault();
    if (!name || !email || !phone || !password || !confirmPassword) {
      setError('Please fill in all fields');
      return;
    }
    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    setLoading(true);
    setError('');

    const res = await ApiService.signup({
      name,
      email,
      phone,
      password,
      confirm_password: confirmPassword,
      currency
    });

    setLoading(false);

    if (res.success) {
      const loginRes = await ApiService.login({ email, password });
      if (loginRes.success) {
        navigate('/home');
      } else {
        navigate('/login');
      }
    } else {
      setError(res.error || 'Signup failed');
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      width: '100vw',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'var(--bg-gradient)',
      padding: '24px'
    }}>
      <div className="mm-card" style={{
        width: '100%',
        maxWidth: '540px',
        padding: '40px',
        boxShadow: '0 20px 50px rgba(0,0,0,0.5)'
      }}>
        <div style={{ textAlign: 'center', marginBottom: '28px' }}>
          <div style={{
            width: '64px',
            height: '64px',
            borderRadius: '20px',
            background: 'var(--primary-gradient)',
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#fff',
            marginBottom: '16px',
            boxShadow: '0 10px 25px rgba(0, 212, 170, 0.35)'
          }}>
            <Wallet size={32} />
          </div>
          <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff', marginBottom: '6px' }}>
            Create MoneyMate Account
          </h1>
          <p style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
            Join thousands managing budgets, savings & EMIs effortlessly
          </p>
        </div>

        {error && (
          <div style={{
            background: 'rgba(255, 77, 106, 0.12)',
            border: '1px solid rgba(255, 77, 106, 0.3)',
            borderRadius: '14px',
            padding: '12px 16px',
            color: 'var(--accent-red)',
            fontSize: '13px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            marginBottom: '20px'
          }}>
            <AlertCircle size={18} />
            {error}
          </div>
        )}

        <form onSubmit={handleSignup}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div className="mm-input-group">
              <label className="mm-input-label">Full Name</label>
              <div style={{ position: 'relative' }}>
                <User size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                <input 
                  type="text" className="mm-input" style={{ paddingLeft: '48px' }}
                  placeholder="John Doe" value={name} onChange={(e) => setName(e.target.value)}
                />
              </div>
            </div>

            <div className="mm-input-group">
              <label className="mm-input-label">Phone Number</label>
              <div style={{ position: 'relative' }}>
                <Phone size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                <input 
                  type="tel" className="mm-input" style={{ paddingLeft: '48px' }}
                  placeholder="+91 9876543210" value={phone} onChange={(e) => setPhone(e.target.value)}
                />
              </div>
            </div>
          </div>

          <div className="mm-input-group">
            <label className="mm-input-label">Email Address</label>
            <div style={{ position: 'relative' }}>
              <Mail size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
              <input 
                type="email" className="mm-input" style={{ paddingLeft: '48px' }}
                placeholder="name@example.com" value={email} onChange={(e) => setEmail(e.target.value)}
              />
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div className="mm-input-group">
              <label className="mm-input-label">Password</label>
              <div style={{ position: 'relative' }}>
                <Lock size={16} style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                <input 
                  type="password" className="mm-input" style={{ paddingLeft: '42px', fontSize: '14px' }}
                  placeholder="••••••••" value={password} onChange={(e) => setPassword(e.target.value)}
                />
              </div>
            </div>

            <div className="mm-input-group">
              <label className="mm-input-label">Confirm Password</label>
              <div style={{ position: 'relative' }}>
                <Lock size={16} style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                <input 
                  type="password" className="mm-input" style={{ paddingLeft: '42px', fontSize: '14px' }}
                  placeholder="••••••••" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)}
                />
              </div>
            </div>
          </div>

          <div className="mm-input-group">
            <label className="mm-input-label">Preferred Currency</label>
            <select 
              className="mm-input" 
              value={currency} 
              onChange={(e) => setCurrency(e.target.value)}
              style={{ cursor: 'pointer' }}
            >
              <option value="INR" style={{ background: '#111827' }}>INR (₹)</option>
              <option value="USD" style={{ background: '#111827' }}>USD ($)</option>
              <option value="EUR" style={{ background: '#111827' }}>EUR (€)</option>
              <option value="GBP" style={{ background: '#111827' }}>GBP (£)</option>
            </select>
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="mm-btn-primary"
            style={{ width: '100%', marginTop: '10px', padding: '15px' }}
          >
            {loading ? 'Creating Account...' : (
              <>
                Register Account <UserPlus size={18} />
              </>
            )}
          </button>
        </form>

        <div style={{ textAlign: 'center', marginTop: '28px' }}>
          <p style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
            Already have an account?{' '}
            <Link to="/login" style={{ color: 'var(--primary)', fontWeight: '600', textDecoration: 'none' }}>
              Sign In
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
