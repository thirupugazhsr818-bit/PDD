// client/src/pages/SpendingChartScreen.jsx
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Chart as ChartJS, CategoryScale, LinearScale, BarElement, 
  PointElement, LineElement, ArcElement, Title, Tooltip, Legend 
} from 'chart.js';
import { Bar, Doughnut } from 'react-chartjs-2';
import { ApiService } from '../services/api';
import MainLayout from '../components/MainLayout';

ChartJS.register(
  CategoryScale, LinearScale, BarElement, PointElement, 
  LineElement, ArcElement, Title, Tooltip, Legend
);

export default function SpendingChartScreen() {
  const [user, setUser] = useState(null);
  const [chartData, setChartData] = useState([]);
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);

  const navigate = useNavigate();

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    const userRes = await ApiService.getCurrentUser();
    if (!userRes.success) {
      navigate('/login');
      return;
    }
    setUser(userRes.data);

    const [chartRes, summaryRes] = await Promise.all([
      ApiService.getMonthlyChart(userRes.data.id),
      ApiService.getTransactionSummary(userRes.data.id)
    ]);

    setLoading(false);
    if (chartRes.success) setChartData(chartRes.data);
    if (summaryRes.success) setSummary(summaryRes.data);
  };

  const currSymbol = user?.currency === 'USD' ? '$' : user?.currency === 'EUR' ? '€' : '₹';

  const monthlyBarConfig = {
    labels: chartData.length > 0 ? chartData.map(d => d.month) : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        label: 'Monthly Expense',
        data: chartData.length > 0 ? chartData.map(d => d.total) : [12000, 15000, 9000, 22000, 18000, 14000],
        backgroundColor: '#00D4AA',
        borderRadius: 8,
        borderSkipped: false,
      }
    ]
  };

  const barOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: '#111827',
        borderColor: '#1E2D45',
        borderWidth: 1,
        titleColor: '#fff',
        bodyColor: '#00D4AA',
      }
    },
    scales: {
      x: { grid: { display: false }, ticks: { color: '#8A9BB8' } },
      y: { grid: { color: '#1E2D45' }, ticks: { color: '#8A9BB8' } }
    }
  };

  const categories = summary?.categories || [];
  const doughnutConfig = {
    labels: categories.map(c => c.category),
    datasets: [
      {
        data: categories.map(c => c.total),
        backgroundColor: [
          '#FF4D6A', '#00D4AA', '#0094FF', '#F5C842', '#9B6DFF', '#FF9900'
        ],
        borderWidth: 0,
      }
    ]
  };

  const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: 'right', labels: { color: '#8A9BB8', font: { size: 13 } } },
      tooltip: { backgroundColor: '#111827', borderColor: '#1E2D45', borderWidth: 1 }
    },
    cutout: '65%'
  };

  return (
    <MainLayout title="Spending Analytics & Trends" user={user}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* Month Summary Bar */}
        {summary && (
          <div className="mm-card" style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px', textAlign: 'center' }}>
            <div>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', display: 'block' }}>Monthly Income</span>
              <strong style={{ fontSize: '22px', color: 'var(--primary)' }}>{currSymbol}{summary.total_income}</strong>
            </div>
            <div>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', display: 'block' }}>Monthly Expense</span>
              <strong style={{ fontSize: '22px', color: 'var(--accent-red)' }}>{currSymbol}{summary.total_expense}</strong>
            </div>
            <div>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', display: 'block' }}>Net Savings Balance</span>
              <strong style={{ fontSize: '22px', color: 'var(--text-primary)' }}>{currSymbol}{summary.net_balance}</strong>
            </div>
          </div>
        )}

        {/* Charts Grid */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))',
          gap: '24px'
        }}>
          {/* Bar Chart */}
          <div className="mm-card">
            <h3 style={{ fontSize: '17px', fontWeight: '700', color: 'var(--text-primary)', marginBottom: '20px' }}>
              6-Month Expense Trend
            </h3>
            <div style={{ height: '320px' }}>
              {loading ? (
                <div style={{ textAlign: 'center', padding: '100px 0', color: 'var(--text-muted)' }}>Loading analytics...</div>
              ) : (
                <Bar data={monthlyBarConfig} options={barOptions} />
              )}
            </div>
          </div>

          {/* Doughnut Chart */}
          <div className="mm-card">
            <h3 style={{ fontSize: '17px', fontWeight: '700', color: 'var(--text-primary)', marginBottom: '20px' }}>
              Category Breakdown
            </h3>
            <div style={{ height: '320px' }}>
              {loading ? (
                <div style={{ textAlign: 'center', padding: '100px 0', color: 'var(--text-muted)' }}>Loading analytics...</div>
              ) : categories.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '80px 20px', color: 'var(--text-muted)' }}>
                  No expenses recorded this month for breakdown.
                </div>
              ) : (
                <Doughnut data={doughnutConfig} options={doughnutOptions} />
              )}
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
