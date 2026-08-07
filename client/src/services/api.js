// client/src/services/api.js

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://pdd-backend-4otv.onrender.com';

async function request(path, options = {}) {
  const headers = { 'Content-Type': 'application/json', ...options.headers };
  const config = { ...options, headers };

  try {
    const res = await fetch(`${BASE_URL}${path}`, config);
    const data = await res.json();
    if (res.ok) {
      return { success: true, data };
    }
    return { success: false, error: data.error || 'Request failed' };
  } catch (err) {
    return { success: false, error: `Network error: ${err.message}` };
  }
}

export const ApiService = {
  // Auth
  signup: (payload) =>
    request('/signup', { method: 'POST', body: JSON.stringify(payload) }),
    
  login: (payload) =>
    request('/login', { method: 'POST', body: JSON.stringify(payload) }),
    
  getCurrentUser: () =>
    request('/get_current_user'),
    
  logout: (email) =>
    request('/logout', { method: 'POST', body: JSON.stringify({ email }) }),

  // Profile
  getProfile: (userId) =>
    request(`/profile/${userId}`),
    
  updateProfile: (userId, payload) =>
    request(`/profile/${userId}`, { method: 'PUT', body: JSON.stringify(payload) }),

  // Dashboard
  getDashboard: (userId, month) => {
    const query = month ? `?month=${encodeURIComponent(month)}` : '';
    return request(`/dashboard/${userId}${query}`);
  },

  // Transactions
  getTransactions: (userId, filters = {}) => {
    const params = new URLSearchParams();
    if (filters.type) params.append('type', filters.type);
    if (filters.category) params.append('category', filters.category);
    if (filters.month) params.append('month', filters.month);
    if (filters.limit) params.append('limit', filters.limit);
    const query = params.toString() ? `?${params.toString()}` : '';
    return request(`/transactions/${userId}${query}`);
  },

  addTransaction: (payload) =>
    request('/transactions', { method: 'POST', body: JSON.stringify(payload) }),

  deleteTransaction: (txnId) =>
    request(`/transactions/${txnId}`, { method: 'DELETE' }),

  getTransactionSummary: (userId, month) => {
    const query = month ? `?month=${encodeURIComponent(month)}` : '';
    return request(`/transactions/summary/${userId}${query}`);
  },

  getMonthlyChart: (userId) =>
    request(`/transactions/monthly_chart/${userId}`),

  // Budgets
  getBudgets: (userId, month) => {
    const query = month ? `?month=${encodeURIComponent(month)}` : '';
    return request(`/budgets/${userId}${query}`);
  },

  addBudget: (payload) =>
    request('/budgets', { method: 'POST', body: JSON.stringify(payload) }),

  updateBudget: (budgetId, amount) =>
    request(`/budgets/${budgetId}`, { method: 'PUT', body: JSON.stringify({ amount }) }),

  deleteBudget: (budgetId) =>
    request(`/budgets/${budgetId}`, { method: 'DELETE' }),

  // Savings Goals
  getSavingsGoals: (userId) =>
    request(`/savings_goals/${userId}`),

  addSavingsGoal: (payload) =>
    request('/savings_goals', { method: 'POST', body: JSON.stringify(payload) }),

  updateSavingsGoal: (goalId, payload) =>
    request(`/savings_goals/${goalId}`, { method: 'PUT', body: JSON.stringify(payload) }),

  deleteSavingsGoal: (goalId) =>
    request(`/savings_goals/${goalId}`, { method: 'DELETE' }),

  addMoneyToGoal: (goalId, amount, note = '') =>
    request(`/savings_goals/${goalId}/add_money`, { method: 'POST', body: JSON.stringify({ amount, note }) }),

  getContributions: (goalId) =>
    request(`/savings_goals/${goalId}/contributions`),

  // EMIs
  getEmis: (userId, status = 'active') =>
    request(`/emis/${userId}?status=${encodeURIComponent(status)}`),

  addEmi: (payload) =>
    request('/emis', { method: 'POST', body: JSON.stringify(payload) }),

  markEmiPaid: (emiId) =>
    request(`/emis/${emiId}/pay`, { method: 'POST', body: JSON.stringify({}) }),

  deleteEmi: (emiId) =>
    request(`/emis/${emiId}`, { method: 'DELETE' }),

  // Bills
  getBills: (userId, isPaid) => {
    const query = isPaid !== undefined && isPaid !== null ? `?is_paid=${isPaid}` : '';
    return request(`/bills/${userId}${query}`);
  },

  addBill: (payload) =>
    request('/bills', { method: 'POST', body: JSON.stringify(payload) }),

  markBillPaid: (billId) =>
    request(`/bills/${billId}/pay`, { method: 'POST', body: JSON.stringify({}) }),

  markBillUnpaid: (billId) =>
    request(`/bills/${billId}/unpay`, { method: 'POST', body: JSON.stringify({}) }),

  deleteBill: (billId) =>
    request(`/bills/${billId}`, { method: 'DELETE' }),

  // Goals (Milestone Tracker)
  getGoals: (userId) =>
    request(`/goals/${userId}`),

  addGoal: (payload) =>
    request('/goals', { method: 'POST', body: JSON.stringify(payload) }),

  updateGoal: (goalId, payload) =>
    request(`/goals/${goalId}`, { method: 'PUT', body: JSON.stringify(payload) }),

  deleteGoal: (goalId) =>
    request(`/goals/${goalId}`, { method: 'DELETE' }),
};
