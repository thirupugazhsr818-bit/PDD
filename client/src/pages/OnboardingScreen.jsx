// client/src/pages/OnboardingScreen.jsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { TrendingUp, PieChart, ShieldCheck, ArrowRight, Check } from 'lucide-react';

export default function OnboardingScreen() {
  const [slide, setSlide] = useState(0);
  const navigate = useNavigate();

  const slides = [
    {
      icon: TrendingUp,
      title: 'Track Expenses Effortlessly',
      desc: 'Keep complete visibility over every rupee spent. Categorize incomes and expenses in real-time.',
      color: '#00D4AA'
    },
    {
      icon: PieChart,
      title: 'Smart Budgeting & Savings',
      desc: 'Set monthly category budgets and set up savings goals to watch your money grow systematically.',
      color: '#0094FF'
    },
    {
      icon: ShieldCheck,
      title: 'Master Bills & EMIs',
      desc: 'Never miss a due date. Track active loans, calculate outstanding balances, and automate bill alerts.',
      color: '#F5C842'
    }
  ];

  const handleNext = () => {
    if (slide < slides.length - 1) {
      setSlide(slide + 1);
    } else {
      navigate('/login');
    }
  };

  const CurrentIcon = slides[slide].icon;

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'space-between',
      padding: '32px 24px',
      background: 'var(--bg-gradient)'
    }}>
      {/* Top Header Bar */}
      <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
        {slide < slides.length - 1 && (
          <button 
            onClick={() => navigate('/login')}
            style={{
              background: 'none',
              border: 'none',
              color: 'var(--text-secondary)',
              fontSize: '14px',
              fontWeight: '600',
              cursor: 'pointer'
            }}
          >
            Skip
          </button>
        )}
      </div>

      {/* Main Slide Content */}
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        textAlign: 'center',
        margin: 'auto 0'
      }}>
        <div style={{
          width: '120px',
          height: '120px',
          borderRadius: '35px',
          background: `rgba(${slides[slide].color === '#00D4AA' ? '0, 212, 170' : slides[slide].color === '#0094FF' ? '0, 148, 255' : '245, 200, 66'}, 0.15)`,
          border: `2px solid ${slides[slide].color}`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: slides[slide].color,
          marginBottom: '36px',
          boxShadow: `0 15px 35px ${slides[slide].color}33`
        }}>
          <CurrentIcon size={60} />
        </div>

        <h2 style={{
          fontSize: '26px',
          fontWeight: '700',
          color: '#fff',
          marginBottom: '14px',
          lineHeight: '1.3'
        }}>
          {slides[slide].title}
        </h2>

        <p style={{
          fontSize: '15px',
          color: 'var(--text-secondary)',
          lineHeight: '1.6',
          maxWidth: '320px'
        }}>
          {slides[slide].desc}
        </p>
      </div>

      {/* Footer / Controls */}
      <div>
        {/* Pagination Dots */}
        <div style={{
          display: 'flex',
          justifyContent: 'center',
          gap: '8px',
          marginBottom: '32px'
        }}>
          {slides.map((_, i) => (
            <div
              key={i}
              onClick={() => setSlide(i)}
              style={{
                width: slide === i ? '28px' : '8px',
                height: '8px',
                borderRadius: '4px',
                background: slide === i ? 'var(--primary)' : 'var(--border)',
                cursor: 'pointer',
                transition: 'all 0.3s ease'
              }}
            />
          ))}
        </div>

        {/* Action Button */}
        <button 
          onClick={handleNext}
          className="mm-btn-primary"
        >
          {slide === slides.length - 1 ? (
            <>
              Get Started <Check size={18} />
            </>
          ) : (
            <>
              Continue <ArrowRight size={18} />
            </>
          )}
        </button>
      </div>
    </div>
  );
}
