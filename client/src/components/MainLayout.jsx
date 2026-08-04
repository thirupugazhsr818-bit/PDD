// client/src/components/MainLayout.jsx
import React, { useState } from 'react';
import Sidebar from './Sidebar';
import Header from './Header';

export default function MainLayout({ title, showBack, user, children }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const toggleSidebar = () => {
    setSidebarOpen(prev => !prev);
  };

  return (
    <div className="web-shell" style={{
      display: 'flex',
      minHeight: '100vh',
      width: '100%',
      background: 'var(--bg-dark)',
      position: 'relative',
      overflowX: 'hidden'
    }}>
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      
      <div className="web-main" style={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        minWidth: 0,
        minHeight: '100vh',
        marginLeft: sidebarOpen ? '270px' : '0px',
        transition: 'margin-left 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        width: sidebarOpen ? 'calc(100% - 270px)' : '100%'
      }}>
        <Header 
          title={title} 
          showBack={showBack} 
          user={user} 
          onToggleSidebar={toggleSidebar}
          isSidebarOpen={sidebarOpen}
        />

        <div className="web-content" style={{
          flex: 1,
          width: '100%',
          padding: '32px 40px',
          boxSizing: 'border-box'
        }}>
          {children}
        </div>
      </div>
    </div>
  );
}
