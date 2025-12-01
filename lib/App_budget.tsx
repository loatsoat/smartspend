import { Settings, Eye, Plus, Building2, Dumbbell, ShoppingCart, ChevronLeft, ChevronRight, DollarSign, X, Calendar as CalendarIcon, Moon, Edit, Trash2, CreditCard, Check, ChevronDown, TrendingUp, ArrowUpRight, ArrowDownRight, Sparkles } from 'lucide-react';
import { useState } from 'react';
import { Calendar } from './components/ui/calendar';
import { motion, AnimatePresence } from 'motion/react';
import { AnimatedBackground } from './components/AnimatedBackground';

// Neon High-Tech Color Palette
const DEFAULT_CATEGORIES = {
  income: {
    name: 'Income',
    color: 'from-[#00F5FF] via-[#00D4FF] to-[#00B8FF]',
    solidColor: '#00F5FF',
    glowColor: 'rgba(0, 245, 255, 0.6)',
    icon: '💰',
    subcategories: ['Income']
  },
  housing: {
    name: 'Housing',
    color: 'from-[#FF6B9D] via-[#FE5196] to-[#FF3D8F]',
    solidColor: '#FF6B9D',
    glowColor: 'rgba(255, 107, 157, 0.6)',
    icon: '🏠',
    subcategories: ['Rent', 'Telephone', 'Insurance', 'Electricity', 'Gym', 'Internet', 'Subscription']
  },
  food: {
    name: 'Food',
    color: 'from-[#A855F7] via-[#9333EA] to-[#7E22CE]',
    solidColor: '#A855F7',
    glowColor: 'rgba(168, 85, 247, 0.6)',
    icon: '🍽️',
    subcategories: ['Groceries', 'Restaurant']
  },
  savings: {
    name: 'Savings',
    color: 'from-[#10F4B1] via-[#00E396] to-[#00D084]',
    solidColor: '#10F4B1',
    glowColor: 'rgba(16, 244, 177, 0.6)',
    icon: '🐷',
    subcategories: ['Emergency funds', 'Vacation fund']
  }
};

interface Transaction {
  id: string;
  type: 'expense' | 'income' | 'transfer';
  amount: number;
  category: string;
  categoryKey: string;
  note: string;
  date: Date;
  excludeFromBudget: boolean;
}

interface PendingTransaction extends Transaction {
  merchant?: string;
  description?: string;
}

interface SubcategoryBudget {
  budgeted: number;
  spent: number;
}

interface CategoryBudget {
  [subcategory: string]: SubcategoryBudget;
}

export default function App() {
  const [activeTab, setActiveTab] = useState<'overview' | 'budget'>('overview');
  const [overviewSubTab, setOverviewSubTab] = useState<'overview' | 'list'>('overview');
  const [showNewTransaction, setShowNewTransaction] = useState(false);
  const [showCategoryPicker, setShowCategoryPicker] = useState(false);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [categories, setCategories] = useState(DEFAULT_CATEGORIES);
  const [selectedCategory, setSelectedCategory] = useState({ name: 'Food', key: 'food' });
  const [showCardConnection, setShowCardConnection] = useState(false);
  const [showCardSwiper, setShowCardSwiper] = useState(false);
  const [isCardConnected, setIsCardConnected] = useState(false);
  const [pendingTransactions, setPendingTransactions] = useState<PendingTransaction[]>([]);
  const [expandedCategories, setExpandedCategories] = useState<string[]>([]);
  const [editingBudget, setEditingBudget] = useState<{ categoryKey: string; subcategory: string } | null>(null);
  const [tempBudgetValue, setTempBudgetValue] = useState('');
  const [isEditingBudgets, setIsEditingBudgets] = useState(false);
  const [tempBudgetValues, setTempBudgetValues] = useState<{ [key: string]: string }>({});
  const [showWeeklySummary, setShowWeeklySummary] = useState(false);
  const [summaryStep, setSummaryStep] = useState(0);
  const [currentMonth, setCurrentMonth] = useState('November');
  const [currentYear, setCurrentYear] = useState(2025);
  const [editingTransaction, setEditingTransaction] = useState<PendingTransaction | null>(null);
  const [showEditTransaction, setShowEditTransaction] = useState(false);
  
  // Budget data - subcategory level budgets
  const [categoryBudgets, setCategoryBudgets] = useState<{ [categoryKey: string]: CategoryBudget }>({
    housing: {
      'Rent': { budgeted: 200, spent: 200 },
      'Gym': { budgeted: 10, spent: 10 }
    },
    food: {
      'Groceries': { budgeted: 30, spent: 30 }
    }
  });

  // Total budget calculations
  const totalBudget = 1000;
  const totalSpent = 240; // 200 + 30 + 10
  const budgetLeft = totalBudget - totalSpent;
  const budgetPercentage = (totalSpent / totalBudget) * 100;

  const handleSaveTransaction = (transaction: Transaction) => {
    setTransactions([transaction, ...transactions]);
    setShowNewTransaction(false);
  };

  const handleCategorySelect = (categoryName: string, categoryKey: string) => {
    setSelectedCategory({ name: categoryName, key: categoryKey });
    setShowCategoryPicker(false);
  };

  const handleAddSubcategory = (categoryKey: string, subcategoryName: string) => {
    setCategories(prev => ({
      ...prev,
      [categoryKey]: {
        ...prev[categoryKey as keyof typeof prev],
        subcategories: [...prev[categoryKey as keyof typeof prev].subcategories, subcategoryName]
      }
    }));
  };

  const handleDeleteSubcategory = (categoryKey: string, subcategoryName: string) => {
    setCategories(prev => ({
      ...prev,
      [categoryKey]: {
        ...prev[categoryKey as keyof typeof prev],
        subcategories: prev[categoryKey as keyof typeof prev].subcategories.filter(s => s !== subcategoryName)
      }
    }));
  };

  const handleConnectCard = () => {
    setIsCardConnected(true);
    const mockTransactions: PendingTransaction[] = [
      {
        id: Date.now().toString() + '1',
        type: 'expense',
        amount: 45.99,
        category: 'Groceries',
        categoryKey: 'food',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'Whole Foods Market',
        description: 'Weekly groceries'
      },
      {
        id: Date.now().toString() + '2',
        type: 'expense',
        amount: 12.50,
        category: 'Restaurant',
        categoryKey: 'food',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'Local Cafe',
        description: 'Lunch'
      },
      {
        id: Date.now().toString() + '3',
        type: 'expense',
        amount: 89.00,
        category: 'Subscription',
        categoryKey: 'housing',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'Netflix',
        description: 'Monthly subscription'
      },
      {
        id: Date.now().toString() + '4',
        type: 'expense',
        amount: 25.00,
        category: 'Gym',
        categoryKey: 'housing',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'FitLife Gym',
        description: 'Monthly membership'
      },
      {
        id: Date.now().toString() + '5',
        type: 'expense',
        amount: 15.99,
        category: 'Internet',
        categoryKey: 'housing',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'ISP Provider',
        description: 'Monthly internet bill'
      },
      {
        id: Date.now().toString() + '6',
        type: 'expense',
        amount: 67.50,
        category: 'Restaurant',
        categoryKey: 'food-drink',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'Olive Garden',
        description: 'Dinner with friends'
      },
      {
        id: Date.now().toString() + '7',
        type: 'expense',
        amount: 120.00,
        category: 'Utilities',
        categoryKey: 'housing',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'Electric Company',
        description: 'Monthly electricity bill'
      },
      {
        id: Date.now().toString() + '8',
        type: 'expense',
        amount: 8.50,
        category: 'Cafe',
        categoryKey: 'food-drink',
        note: '',
        date: new Date(),
        excludeFromBudget: false,
        merchant: 'Local Coffee Shop',
        description: 'Afternoon latte'
      }
    ];
    setPendingTransactions(mockTransactions);
    setShowCardConnection(false);
    setShowCardSwiper(true);
  };

  const handleCardSwipeRight = (transaction: PendingTransaction) => {
    // Directly add to list
    setTransactions([transaction, ...transactions]);
    setPendingTransactions(prev => prev.filter(t => t.id !== transaction.id));
  };

  const handleCardSwipeLeft = (transaction: PendingTransaction) => {
    // Open edit modal
    setEditingTransaction(transaction);
    setShowEditTransaction(true);
    setPendingTransactions(prev => prev.filter(t => t.id !== transaction.id));
  };

  const handleSaveEditedTransaction = (transaction: Transaction) => {
    setTransactions([transaction, ...transactions]);
    setShowEditTransaction(false);
    setEditingTransaction(null);
  };

  const toggleCategory = (categoryKey: string) => {
    setExpandedCategories(prev => 
      prev.includes(categoryKey) 
        ? prev.filter(k => k !== categoryKey)
        : [...prev, categoryKey]
    );
  };

  const startEditingBudget = (categoryKey: string, subcategory: string) => {
    const currentBudget = categoryBudgets[categoryKey]?.[subcategory]?.budgeted || 0;
    setEditingBudget({ categoryKey, subcategory });
    setTempBudgetValue(currentBudget.toString());
  };

  const saveBudgetEdit = () => {
    if (editingBudget) {
      const newBudget = parseFloat(tempBudgetValue) || 0;
      setCategoryBudgets(prev => ({
        ...prev,
        [editingBudget.categoryKey]: {
          ...prev[editingBudget.categoryKey],
          [editingBudget.subcategory]: {
            ...prev[editingBudget.categoryKey]?.[editingBudget.subcategory],
            budgeted: newBudget
          }
        }
      }));
      setEditingBudget(null);
      setTempBudgetValue('');
    }
  };

  const enterEditMode = () => {
    setIsEditingBudgets(true);
    // Initialize temp values with current budgets for all subcategories
    const tempValues: { [key: string]: string } = {};
    Object.entries(categories).forEach(([categoryKey, categoryData]) => {
      categoryData.subcategories.forEach((subcategory) => {
        const currentBudget = categoryBudgets[categoryKey]?.[subcategory]?.budgeted || 0;
        tempValues[`${categoryKey}-${subcategory}`] = currentBudget.toString();
      });
    });
    setTempBudgetValues(tempValues);
  };

  const saveAllBudgets = () => {
    const newBudgets = { ...categoryBudgets };
    Object.entries(tempBudgetValues).forEach(([key, value]) => {
      const parts = key.split('-');
      const categoryKey = parts[0];
      const subcategory = parts.slice(1).join('-'); // Handle subcategories with dashes in name
      const newBudget = parseFloat(value) || 0;
      if (!newBudgets[categoryKey]) {
        newBudgets[categoryKey] = {};
      }
      const currentSpent = newBudgets[categoryKey][subcategory]?.spent || 0;
      newBudgets[categoryKey][subcategory] = {
        budgeted: newBudget,
        spent: currentSpent
      };
    });
    setCategoryBudgets(newBudgets);
    setIsEditingBudgets(false);
    setTempBudgetValues({});
  };

  const cancelEditMode = () => {
    setIsEditingBudgets(false);
    setTempBudgetValues({});
  };

  const handlePreviousMonth = () => {
    if (currentMonth === 'November') {
      setCurrentMonth('October');
    } else if (currentMonth === 'October') {
      setCurrentMonth('September');
    }
  };

  const handleNextMonth = () => {
    if (currentMonth === 'October') {
      setCurrentMonth('November');
    } else if (currentMonth === 'September') {
      setCurrentMonth('October');
    }
  };

  const getMonthTransactions = () => {
    const monthMap: { [key: string]: number } = {
      'January': 0, 'February': 1, 'March': 2, 'April': 3, 'May': 4, 'June': 5,
      'July': 6, 'August': 7, 'September': 8, 'October': 9, 'November': 10, 'December': 11
    };
    
    const currentMonthNum = monthMap[currentMonth];
    
    return transactions.filter(t => {
      const tDate = new Date(t.date);
      return tDate.getMonth() === currentMonthNum && tDate.getFullYear() === currentYear;
    });
  };

  const monthTransactions = getMonthTransactions();

  const groupedTransactions = monthTransactions.reduce((acc: any, transaction) => {
    const date = new Date(transaction.date);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    let dateLabel = '';
    if (date.toDateString() === today.toDateString()) {
      dateLabel = 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
      dateLabel = 'Yesterday';
    } else {
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateLabel = `${days[date.getDay()]}, ${String(date.getDate()).padStart(2, '0')} ${months[date.getMonth()]}`;
    }

    if (!acc[dateLabel]) {
      acc[dateLabel] = [];
    }
    acc[dateLabel].push(transaction);
    return acc;
  }, {});

  if (showCategoryPicker) {
    return (
      <CategoryPickerScreen 
        onClose={() => setShowCategoryPicker(false)} 
        onSelect={handleCategorySelect}
        categories={categories}
        onAddSubcategory={handleAddSubcategory}
        onDeleteSubcategory={handleDeleteSubcategory}
      />
    );
  }

  if (showWeeklySummary) {
    return <WeeklySummaryFlow step={summaryStep} onNext={() => setSummaryStep(summaryStep + 1)} onClose={() => { setShowWeeklySummary(false); setSummaryStep(0); }} />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#0A0E1A] via-[#1A1F33] to-[#0A0E1A] pb-20 relative">
      <AnimatedBackground />
      <AnimatePresence mode="wait">
        {activeTab === 'budget' ? (
          <motion.div
            key="budget"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3, ease: "easeOut" }}
            className="relative z-10"
          >
            {/* Status Bar */}
            <div className="flex justify-between items-center px-8 py-4 bg-gradient-to-r from-[#1a1f3a] via-[#2a2f4a] to-[#1a1f3a] border-b border-cyan-500/20 shadow-[0_4px_20px_rgba(0,245,255,0.1)]">
              <span className="text-white/90">23:34 Tuesday 4 Nov.</span>
              <div className="flex items-center gap-2">
                <span className="text-white/90">100%</span>
                <div className="w-6 h-3 border border-cyan-400/60 rounded-sm relative shadow-[0_0_10px_rgba(0,245,255,0.3)]">
                  <div className="absolute inset-0.5 bg-gradient-to-r from-cyan-400 to-blue-400 rounded-sm"></div>
                </div>
              </div>
            </div>

            {/* Header */}
            <div className="px-8 py-5 bg-gradient-to-r from-[#1a1f3a] via-[#2a2f4a] to-[#1a1f3a] flex items-center justify-between border-b border-purple-500/20 shadow-[0_4px_20px_rgba(168,85,247,0.15)]">
              <motion.button whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.95 }}>
                <Settings className="text-white" size={24} strokeWidth={1.5} />
              </motion.button>
              <div className="flex items-center gap-2">
                <span className="text-white/90 tracking-wide">Personal Wallet</span>
              </div>
              {isEditingBudgets ? (
                <motion.button 
                  onClick={saveAllBudgets}
                  whileHover={{ scale: 1.1 }} 
                  whileTap={{ scale: 0.95 }}
                  className="text-white/90 hover:text-white transition-colors"
                >
                  <Check size={24} strokeWidth={1.5} />
                </motion.button>
              ) : (
                <motion.button 
                  onClick={enterEditMode}
                  whileHover={{ scale: 1.1 }} 
                  whileTap={{ scale: 0.95 }}
                  className="text-white/90 hover:text-white transition-colors"
                >
                  <Edit size={24} strokeWidth={1.5} />
                </motion.button>
              )}
            </div>

            {/* Budget Content */}
            <div className="max-w-[480px] mx-auto px-6 mt-6 pb-6">
              
              {/* Circular Budget Chart */}
              <motion.div 
                className="backdrop-blur-xl rounded-[2rem] p-8 border border-cyan-500/30 mb-6 relative overflow-hidden"
                style={{
                  background: 'linear-gradient(135deg, rgba(0,245,255,0.15), rgba(168,85,247,0.12), rgba(26,31,58,0.95), rgba(255,107,157,0.08))',
                  boxShadow: '0 0 50px rgba(0,245,255,0.25), 0 0 100px rgba(168,85,247,0.2), inset 0 0 100px rgba(0,245,255,0.05)'
                }}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
              >
                <div className="flex justify-center items-center mb-8 relative">
                  <svg width="280" height="280" viewBox="0 0 280 280" className="transform -rotate-90">
                    {/* Background circle */}
                    <circle cx="140" cy="140" r="120" fill="none" stroke="#1f2937" strokeWidth="28" />
                    
                    {/* Filled portion - showing spent budget */}
                    <motion.circle 
                      cx="140" cy="140" r="120" 
                      fill="none" 
                      stroke="url(#budgetGradient)" 
                      strokeWidth="28" 
                      strokeDasharray="754" 
                      strokeDashoffset={754 - (754 * (budgetPercentage / 100))}
                      strokeLinecap="round"
                      filter="url(#neonGlow)"
                      initial={{ strokeDashoffset: 754 }}
                      animate={{ strokeDashoffset: 754 - (754 * (budgetPercentage / 100)) }}
                      transition={{ duration: 1.5, ease: "easeOut" }}
                    />
                    
                    <defs>
                      <linearGradient id="budgetGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" stopColor="#00F5FF" />
                        <stop offset="33%" stopColor="#A855F7" />
                        <stop offset="66%" stopColor="#FF6B9D" />
                        <stop offset="100%" stopColor="#10F4B1" />
                      </linearGradient>
                      <filter id="neonGlow">
                        <feGaussianBlur stdDeviation="4" result="coloredBlur"/>
                        <feMerge>
                          <feMergeNode in="coloredBlur"/>
                          <feMergeNode in="SourceGraphic"/>
                        </feMerge>
                      </filter>
                    </defs>
                  </svg>
                  
                  <motion.div 
                    className="absolute inset-0 flex flex-col items-center justify-center"
                    initial={{ scale: 0.8, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ delay: 0.6 }}
                  >
                    <div className="text-white/40 text-[11px] tracking-widest uppercase mb-2">Budget Left</div>
                    <div className="text-white text-[52px] leading-none tracking-tight">{budgetLeft} €</div>
                    <div className="text-white/40 text-[13px] tracking-wide mt-2">of {totalBudget} €</div>
                  </motion.div>
                </div>
              </motion.div>

              {/* Categories with Budgets */}
              <motion.div
                className="space-y-3"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
              >
                {Object.entries(categories).map(([categoryKey, categoryData], idx) => {
                  const isExpanded = expandedCategories.includes(categoryKey);
                  const categoryBudgetData = categoryBudgets[categoryKey] || {};

                  return (
                    <motion.div
                      key={categoryKey}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: idx * 0.05 }}
                    >
                      {/* Main Category */}
                      <motion.button
                        onClick={() => toggleCategory(categoryKey)}
                        className="w-full backdrop-blur-sm rounded-3xl p-6 border border-white/20 hover:border-white/30 transition-all relative overflow-hidden"
                        whileHover={{ scale: 1.01 }}
                        whileTap={{ scale: 0.99 }}
                        style={{
                          background: `linear-gradient(135deg, ${categoryData.glowColor}20, ${categoryData.glowColor}05, rgba(26, 31, 58, 0.6))`,
                          boxShadow: `0 0 30px ${categoryData.glowColor}20, 0 0 60px ${categoryData.glowColor}10, inset 0 0 80px ${categoryData.glowColor}05`
                        }}
                      >
                        <div className="flex items-center gap-4">
                          <div 
                            className={`w-16 h-16 rounded-2xl bg-gradient-to-br ${categoryData.color} flex items-center justify-center`}
                            style={{
                              boxShadow: `0 0 30px ${categoryData.glowColor}, 0 0 60px ${categoryData.glowColor}40, inset 0 0 20px ${categoryData.glowColor}30`
                            }}
                          >
                            <span className="text-3xl drop-shadow-[0_0_10px_rgba(255,255,255,0.5)]">{categoryData.icon}</span>
                          </div>
                          <div className="flex-1 text-left">
                            <div className="text-white text-[18px] mb-1">{categoryData.name}</div>
                            <div className="text-white/50 text-[13px]">
                              {categoryData.subcategories.length} categories
                            </div>
                          </div>
                          <motion.div
                            animate={{ rotate: isExpanded ? 180 : 0 }}
                            transition={{ duration: 0.2 }}
                          >
                            <ChevronDown className="text-white/40" size={24} />
                          </motion.div>
                        </div>
                      </motion.button>

                      {/* Subcategories */}
                      <AnimatePresence>
                        {isExpanded && (
                          <motion.div
                            initial={{ opacity: 0, height: 0 }}
                            animate={{ opacity: 1, height: "auto" }}
                            exit={{ opacity: 0, height: 0 }}
                            transition={{ duration: 0.3 }}
                            className="mt-2 ml-6 space-y-2"
                          >
                            {categoryData.subcategories.map((subcategory, subIdx) => {
                              const budgetData = categoryBudgetData[subcategory] || { budgeted: 0, spent: 0 };
                              const remaining = budgetData.budgeted - budgetData.spent;
                              const percentage = budgetData.budgeted > 0 ? (budgetData.spent / budgetData.budgeted) * 100 : 0;
                              const tempKey = `${categoryKey}-${subcategory}`;

                              return (
                                <motion.div
                                  key={subcategory}
                                  initial={{ opacity: 0, x: -10 }}
                                  animate={{ opacity: 1, x: 0 }}
                                  transition={{ delay: subIdx * 0.05 }}
                                  className="backdrop-blur-sm rounded-2xl p-5 border border-white/15"
                                  style={{
                                    background: `linear-gradient(120deg, ${categoryData.glowColor}15, ${categoryData.glowColor}03, rgba(26, 31, 58, 0.5))`,
                                    boxShadow: `0 0 20px ${categoryData.glowColor}15, inset 0 0 40px ${categoryData.glowColor}03`
                                  }}
                                >
                                  <div className="flex items-center justify-between mb-3">
                                    <div className="flex items-center gap-3">
                                      <div 
                                        className="w-2 h-2 rounded-full" 
                                        style={{ backgroundColor: categoryData.solidColor }}
                                      />
                                      <span className="text-white text-[15px]">{subcategory}</span>
                                    </div>
                                    
                                    {isEditingBudgets ? (
                                      <div className="flex items-center gap-2">
                                        <span className="text-white/60 text-[14px]">€</span>
                                        <input
                                          type="number"
                                          value={tempBudgetValues[tempKey] || '0'}
                                          onChange={(e) => setTempBudgetValues(prev => ({
                                            ...prev,
                                            [tempKey]: e.target.value
                                          }))}
                                          className="w-24 px-3 py-2 bg-white/10 text-white text-[15px] rounded-xl outline-none border border-white/20 focus:border-[#7BC9A6] transition-colors"
                                          placeholder="0"
                                        />
                                      </div>
                                    ) : (
                                      <div className="text-right">
                                        {budgetData.budgeted > 0 ? (
                                          <>
                                            <div className="text-white text-[16px]">€{remaining.toFixed(0)}</div>
                                            <div className="text-white/40 text-[12px]">
                                              of €{budgetData.budgeted.toFixed(0)}
                                            </div>
                                          </>
                                        ) : (
                                          <div className="text-white/40 text-[14px]">No budget set</div>
                                        )}
                                      </div>
                                    )}
                                  </div>
                                  
                                  {/* Progress bar */}
                                  {!isEditingBudgets && budgetData.budgeted > 0 && (
                                    <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                                      <motion.div
                                        className={`h-full bg-gradient-to-r ${categoryData.color}`}
                                        style={{
                                          boxShadow: `0 0 15px ${categoryData.glowColor}, 0 0 30px ${categoryData.glowColor}60`
                                        }}
                                        initial={{ width: 0 }}
                                        animate={{ width: `${Math.min(percentage, 100)}%` }}
                                        transition={{ duration: 0.8, delay: subIdx * 0.1 }}
                                      />
                                    </div>
                                  )}
                                </motion.div>
                              );
                            })}
                          </motion.div>
                        )}
                      </AnimatePresence>
                    </motion.div>
                  );
                })}
              </motion.div>
            </div>
          </motion.div>
        ) : (
          <motion.div
            key="overview"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3, ease: "easeOut" }}
            className="relative z-10"
          >
            {/* Status Bar */}
            <div className="flex justify-between items-center px-8 py-4 bg-gradient-to-r from-[#1a1f3a] via-[#2a2f4a] to-[#1a1f3a] border-b border-cyan-500/20 shadow-[0_4px_20px_rgba(0,245,255,0.1)]">
              <span className="text-white/90">23:34 Tuesday 4 Nov.</span>
              <div className="flex items-center gap-2">
                <span className="text-white/90">100%</span>
                <div className="w-6 h-3 border border-cyan-400/60 rounded-sm relative shadow-[0_0_10px_rgba(0,245,255,0.3)]">
                  <div className="absolute inset-0.5 bg-gradient-to-r from-cyan-400 to-blue-400 rounded-sm"></div>
                </div>
              </div>
            </div>

            {/* Header */}
            <div className="px-8 py-5 bg-gradient-to-r from-[#1a1f3a] via-[#2a2f4a] to-[#1a1f3a] flex items-center justify-between border-b border-purple-500/20 shadow-[0_4px_20px_rgba(168,85,247,0.15)]">
              <motion.button whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.95 }}>
                <Settings className="text-white" size={24} strokeWidth={1.5} />
              </motion.button>
              <div className="flex items-center gap-2">
                <span className="text-white/90 tracking-wide">Personal Wallet</span>
              </div>
              <div className="w-6"></div>
            </div>

            {/* Sub-Tabs for Overview */}
            <div className="flex justify-center py-6 bg-gradient-to-r from-[#1a1f3a] via-[#2a2f4a] to-[#1a1f3a] border-b border-cyan-500/10">
              <div className="flex gap-3 bg-gradient-to-r from-white/10 to-white/5 backdrop-blur-md rounded-full p-1 shadow-[0_0_30px_rgba(0,245,255,0.2)] border border-cyan-400/30">
                <motion.button 
                  onClick={() => setOverviewSubTab('overview')} 
                  className={`px-4 py-1.5 rounded-full text-xs transition-all ${
                    overviewSubTab === 'overview' ? 'bg-gradient-to-r from-cyan-400 to-blue-500 text-white shadow-[0_0_20px_rgba(0,245,255,0.6)]' : 'text-white/70 hover:text-white'
                  }`}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  OVERVIEW
                </motion.button>
                <motion.button 
                  onClick={() => setOverviewSubTab('list')} 
                  className={`px-4 py-1.5 rounded-full text-xs transition-all ${
                    overviewSubTab === 'list' ? 'bg-gradient-to-r from-cyan-400 to-blue-500 text-white shadow-[0_0_20px_rgba(0,245,255,0.6)]' : 'text-white/70 hover:text-white'
                  }`}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  LIST
                </motion.button>
              </div>
            </div>

            {/* Overview Content */}
            <AnimatePresence mode="wait">
              {overviewSubTab === 'overview' ? (
                <motion.div
                  key="overview-content"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  transition={{ duration: 0.2 }}
                  className="max-w-[480px] mx-auto px-6 mt-6"
                >
                  {/* Budget Graph */}
                  <motion.div 
                    className="backdrop-blur-xl rounded-[2rem] p-6 border border-cyan-500/30 mb-6 relative overflow-hidden"
                    style={{
                      background: 'linear-gradient(135deg, rgba(0,245,255,0.15), rgba(168,85,247,0.1), rgba(26,31,58,0.95), rgba(255,107,157,0.08))',
                      boxShadow: '0 0 50px rgba(0,245,255,0.25), 0 0 100px rgba(168,85,247,0.2), inset 0 0 100px rgba(0,245,255,0.05)'
                    }}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 }}
                  >
                    <div className="text-white/60 text-[11px] tracking-widest uppercase mb-4">PERSONAL WALLET</div>
                    
                    {/* Budget Bar Chart */}
                    <div className="space-y-6">
                      <div>
                        <div className="mb-4">
                          <div className="text-white text-[32px] leading-none tracking-tight">{budgetLeft} € left to spend</div>
                        </div>
                        
                        {/* Bar - Spent on left, blank on right */}
                        <div className="relative h-16 bg-white/5 rounded-2xl overflow-hidden border border-white/10">
                          <motion.div
                            className="absolute inset-y-0 left-0 bg-gradient-to-r from-[#FF6B9D] via-[#FE5196] to-[#FF3D8F] flex items-center justify-center"
                            style={{
                              boxShadow: '0 0 30px rgba(255,107,157,0.6), inset 0 0 20px rgba(255,255,255,0.2)'
                            }}
                            initial={{ width: 0 }}
                            animate={{ width: `${(totalSpent / totalBudget) * 100}%` }}
                            transition={{ duration: 1.5, ease: "easeOut", delay: 0.3 }}
                          >
                            <span className="text-white text-[12px] tracking-wider drop-shadow-[0_0_10px_rgba(255,255,255,0.8)]">{((totalSpent / totalBudget) * 100).toFixed(0)}%</span>
                          </motion.div>
                        </div>
                      </div>

                      {/* Quick Stats */}
                      <div className="grid grid-cols-3 gap-3 pt-4 border-t border-white/5">
                        <div>
                          <div className="text-white/40 text-[10px] tracking-wider uppercase mb-1">Income</div>
                          <div className="flex items-center gap-1">
                            <div className="p-1 rounded-lg bg-gradient-to-br from-[#10F4B1] to-[#00E396] shadow-[0_0_15px_rgba(16,244,177,0.5)]">
                              <ArrowUpRight className="text-white" size={14} />
                            </div>
                            <span className="text-white text-[16px]">1,442€</span>
                          </div>
                        </div>
                        <div>
                          <div className="text-white/40 text-[10px] tracking-wider uppercase mb-1">Expenses</div>
                          <div className="flex items-center gap-1">
                            <div className="p-1 rounded-lg bg-gradient-to-br from-[#FF6B9D] to-[#FE5196] shadow-[0_0_15px_rgba(255,107,157,0.5)]">
                              <ArrowDownRight className="text-white" size={14} />
                            </div>
                            <span className="text-white text-[16px]">{totalSpent}€</span>
                          </div>
                        </div>
                        <div>
                          <div className="text-white/40 text-[10px] tracking-wider uppercase mb-1">Saved</div>
                          <div className="flex items-center gap-1">
                            <div className="p-1 rounded-lg bg-gradient-to-br from-[#00F5FF] to-[#00D4FF] shadow-[0_0_15px_rgba(0,245,255,0.5)]">
                              <TrendingUp className="text-white" size={14} />
                            </div>
                            <span className="text-white text-[16px]">{budgetLeft}€</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </motion.div>

                  {/* Weekend Wrap-Up Widget */}
                  <motion.button
                    onClick={() => {
                      setShowWeeklySummary(true);
                      setSummaryStep(0);
                    }}
                    className="w-full bg-gradient-to-br from-[#A855F7] via-[#9333EA] to-[#7E22CE] rounded-[2rem] p-8 shadow-[0_0_40px_rgba(168,85,247,0.6),0_0_80px_rgba(168,85,247,0.3)] border border-purple-400/30 relative overflow-hidden"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 }}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    {/* Decorative elements with glow */}
                    <div className="absolute top-4 right-4 text-6xl opacity-30 drop-shadow-[0_0_20px_rgba(255,255,255,0.5)]">💸</div>
                    <div className="absolute bottom-4 left-4 text-4xl opacity-20 drop-shadow-[0_0_15px_rgba(255,255,255,0.4)]">✨</div>
                    
                    {/* Animated gradient orb */}
                    <motion.div
                      className="absolute -top-10 -right-10 w-40 h-40 rounded-full bg-gradient-to-br from-pink-400/30 to-purple-600/30 blur-3xl"
                      animate={{
                        scale: [1, 1.2, 1],
                        opacity: [0.3, 0.5, 0.3],
                      }}
                      transition={{
                        duration: 4,
                        repeat: Infinity,
                        ease: "easeInOut",
                      }}
                    />
                    
                    <div className="relative z-10">
                      <div className="flex items-center gap-2 mb-3">
                        <Sparkles className="text-white drop-shadow-[0_0_10px_rgba(255,255,255,0.8)]" size={20} />
                        <span className="text-white/90 text-[11px] tracking-widest uppercase">Weekly Insights</span>
                      </div>
                      <h2 className="text-white text-[28px] leading-tight mb-2">
                        See what your money was up to last week
                      </h2>
                      <p className="text-white/80 text-[14px] mb-6">Here's your breakdown</p>
                      
                      <div className="bg-gradient-to-r from-white/20 to-white/10 backdrop-blur-sm rounded-2xl px-6 py-4 text-white text-center text-[15px] tracking-wide border border-white/20 shadow-[0_0_20px_rgba(255,255,255,0.2)]">
                        Open weekly summary
                      </div>
                    </div>
                  </motion.button>
                </motion.div>
              ) : (
                <motion.div
                  key="list-content"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  transition={{ duration: 0.2 }}
                  className="px-4 pt-4 pb-24 max-w-[480px] mx-auto"
                >
                  {/* Month Selector */}
                  <motion.div 
                    className="backdrop-blur-xl rounded-[2rem] p-6 mb-4 flex items-center justify-between border border-cyan-500/30 relative overflow-hidden"
                    style={{
                      background: 'linear-gradient(135deg, rgba(0,245,255,0.12), rgba(168,85,247,0.08), rgba(26,31,58,0.9))',
                      boxShadow: '0 0 40px rgba(0,245,255,0.2), inset 0 0 80px rgba(0,245,255,0.03)'
                    }}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                  >
                    <motion.button 
                      onClick={handlePreviousMonth} 
                      whileHover={{ scale: 1.1, x: -2 }}
                      whileTap={{ scale: 0.95 }}
                      transition={{ type: "spring", stiffness: 400 }}
                      className="p-2 rounded-xl bg-gradient-to-br from-cyan-400/20 to-blue-500/20 border border-cyan-400/30"
                    >
                      <ChevronLeft className="text-cyan-400" size={24} />
                    </motion.button>
                    <div className="text-center">
                      <div className="text-white text-[20px] mb-1">{currentMonth} {currentYear}</div>
                      <div className="text-white/50 text-[11px] tracking-wider uppercase flex items-center justify-center gap-2">
                        {monthTransactions.length} TRANSACTIONS
                        <motion.span 
                          className="w-2 h-2 rounded-full bg-gradient-to-r from-[#FF6B9D] to-[#FE5196] shadow-[0_0_10px_rgba(255,107,157,0.8)]"
                          animate={{ scale: [1, 1.2, 1] }}
                          transition={{ duration: 2, repeat: Infinity }}
                        />
                      </div>
                    </div>
                    <motion.button 
                      onClick={handleNextMonth} 
                      whileHover={{ scale: 1.1, x: 2 }}
                      whileTap={{ scale: 0.95 }}
                      transition={{ type: "spring", stiffness: 400 }}
                      className="p-2 rounded-xl bg-gradient-to-br from-cyan-400/20 to-blue-500/20 border border-cyan-400/30"
                    >
                      <ChevronRight className="text-cyan-400" size={24} />
                    </motion.button>
                  </motion.div>

                  {/* Transaction List */}
                  {Object.keys(groupedTransactions).length > 0 ? (
                    <motion.div 
                      className="backdrop-blur-xl rounded-[2rem] border border-purple-500/30 overflow-hidden relative"
                      style={{
                        background: 'linear-gradient(135deg, rgba(168,85,247,0.12), rgba(255,107,157,0.08), rgba(26,31,58,0.9), rgba(16,244,177,0.05))',
                        boxShadow: '0 0 40px rgba(168,85,247,0.2), inset 0 0 80px rgba(168,85,247,0.03)'
                      }}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.1 }}
                    >
                      {Object.entries(groupedTransactions).map(([dateLabel, transactions]: [string, any], idx) => (
                        <motion.div 
                          key={idx} 
                          className={`p-6 ${idx < Object.keys(groupedTransactions).length - 1 ? 'border-b border-white/5' : ''}`}
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: idx * 0.1 }}
                        >
                          <div className="text-white/50 text-[11px] tracking-wider uppercase mb-4">{dateLabel}</div>
                          {transactions.map((transaction: Transaction, itemIdx: number) => {
                            const categoryData = categories[transaction.categoryKey as keyof typeof categories];
                            return (
                              <div key={transaction.id} className={itemIdx > 0 ? 'mt-4' : ''}>
                                <TransactionItem 
                                  icon={<span className="text-xl">{categoryData?.icon || '📦'}</span>}
                                  label={transaction.category} 
                                  amount={`${transaction.type === 'income' ? '+' : '-'}${transaction.amount.toFixed(2)} €`}
                                  color={categoryData?.color || 'from-[#6B7C8F] to-[#4A5C6F]'} 
                                />
                              </div>
                            );
                          })}
                        </motion.div>
                      ))}
                    </motion.div>
                  ) : (
                    <motion.div 
                      className="backdrop-blur-xl rounded-[2rem] border border-purple-500/30 p-12 text-center relative overflow-hidden"
                      style={{
                        background: 'linear-gradient(135deg, rgba(168,85,247,0.12), rgba(26,31,58,0.9))',
                        boxShadow: '0 0 40px rgba(168,85,247,0.2), inset 0 0 80px rgba(168,85,247,0.03)'
                      }}
                      initial={{ opacity: 0, scale: 0.9 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: 0.1 }}
                    >
                      <div className="text-white/40 text-[15px]">No transactions this month</div>
                      <div className="text-white/20 text-[13px] mt-2">Tap the + button to add one</div>
                    </motion.div>
                  )}
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bottom Navigation */}
      <motion.div 
        className="fixed bottom-0 left-0 right-0 bg-gradient-to-r from-[#1a1f3a]/95 via-[#2a2f4a]/95 to-[#1a1f3a]/95 backdrop-blur-lg border-t border-cyan-500/20 shadow-[0_-4px_30px_rgba(0,245,255,0.1)] z-50"
        initial={{ y: 100 }}
        animate={{ y: 0 }}
        transition={{ type: "spring", stiffness: 300, damping: 30 }}
      >
        <div className="flex justify-around items-center px-6 py-4 relative">
          <motion.button
            onClick={() => setActiveTab('overview')}
            className="flex flex-col items-center gap-1 transition-colors relative"
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.95 }}
          >
            <div className={`p-2 rounded-2xl transition-all ${
              activeTab === 'overview' 
                ? 'bg-gradient-to-br from-[#00F5FF] via-[#00D4FF] to-[#00B8FF] shadow-[0_0_30px_rgba(0,245,255,0.6)]' 
                : 'bg-transparent'
            }`}>
              <Eye size={24} className={activeTab === 'overview' ? 'text-white' : 'text-white/40'} />
            </div>
            <span className={`text-[11px] ${activeTab === 'overview' ? 'text-white' : 'text-white/40'}`}>Overview</span>
          </motion.button>
          
          {/* Center Plus Button */}
          <motion.button 
            onClick={() => setShowNewTransaction(true)}
            className="absolute left-1/2 -translate-x-1/2 -top-8 w-16 h-16 rounded-full bg-gradient-to-br from-[#FF6B9D] via-[#FE5196] to-[#FF3D8F] shadow-[0_0_40px_rgba(255,107,157,0.8),0_10px_30px_rgba(0,0,0,0.3)] flex items-center justify-center"
            whileHover={{ scale: 1.1, rotate: 90 }}
            whileTap={{ scale: 0.95 }}
            transition={{ type: "spring", stiffness: 400 }}
          >
            <Plus className="text-white drop-shadow-[0_0_10px_rgba(255,255,255,0.5)]" size={32} strokeWidth={2.5} />
          </motion.button>

          <motion.button
            onClick={() => setActiveTab('budget')}
            className="flex flex-col items-center gap-1 transition-colors relative"
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.95 }}
          >
            <div className={`p-2 rounded-2xl transition-all ${
              activeTab === 'budget' 
                ? 'bg-gradient-to-br from-[#A855F7] via-[#9333EA] to-[#7E22CE] shadow-[0_0_30px_rgba(168,85,247,0.6)]' 
                : 'bg-transparent'
            }`}>
              <DollarSign size={24} className={activeTab === 'budget' ? 'text-white' : 'text-white/40'} />
            </div>
            <span className={`text-[11px] ${activeTab === 'budget' ? 'text-white' : 'text-white/40'}`}>Budget</span>
          </motion.button>
        </div>
      </motion.div>

      {/* New Transaction Modal */}
      <AnimatePresence>
        {showNewTransaction && (
          <NewTransactionModal 
            onClose={() => setShowNewTransaction(false)} 
            onOpenCategories={() => setShowCategoryPicker(true)}
            onSave={handleSaveTransaction}
            selectedCategory={selectedCategory}
            categories={categories}
          />
        )}
      </AnimatePresence>

      {/* Edit Transaction Modal */}
      <AnimatePresence>
        {showEditTransaction && editingTransaction && (
          <EditTransactionModal 
            onClose={() => {
              setShowEditTransaction(false);
              setEditingTransaction(null);
            }}
            onOpenCategories={() => setShowCategoryPicker(true)}
            onSave={handleSaveEditedTransaction}
            transaction={editingTransaction}
            categories={categories}
          />
        )}
      </AnimatePresence>

      {/* Virtual Button - Bottom Right */}
      <motion.button
        onClick={() => setShowCardConnection(true)}
        className="fixed bottom-24 right-6 w-14 h-14 rounded-full bg-gradient-to-br from-[#C29FBD] to-[#9B7EBD] shadow-2xl flex items-center justify-center z-40"
        whileHover={{ scale: 1.1, rotate: 15 }}
        whileTap={{ scale: 0.95 }}
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ type: "spring", stiffness: 300, delay: 0.5 }}
      >
        <CreditCard className="text-white" size={24} />
      </motion.button>

      {/* Card Connection Modal */}
      <AnimatePresence>
        {showCardConnection && (
          <CardConnectionModal 
            onClose={() => setShowCardConnection(false)}
            onConnect={handleConnectCard}
            isConnected={isCardConnected}
          />
        )}
      </AnimatePresence>

      {/* Transaction Card Swiper */}
      <AnimatePresence>
        {showCardSwiper && pendingTransactions.length > 0 && (
          <TransactionCardSwiper
            transactions={pendingTransactions}
            onSwipeRight={handleCardSwipeRight}
            onSwipeLeft={handleCardSwipeLeft}
            onClose={() => setShowCardSwiper(false)}
            categories={categories}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function TransactionItem({ icon, label, amount, color }: { icon: React.ReactNode; label: string; amount: string; color: string }) {
  // Get the glow color from the gradient class
  const glowColors: { [key: string]: string } = {
    'from-[#00F5FF]': 'rgba(0, 245, 255, 0.6)',
    'from-[#FF6B9D]': 'rgba(255, 107, 157, 0.6)',
    'from-[#A855F7]': 'rgba(168, 85, 247, 0.6)',
    'from-[#10F4B1]': 'rgba(16, 244, 177, 0.6)',
  };
  
  const glowColor = Object.entries(glowColors).find(([key]) => color.includes(key))?.[1] || 'rgba(168, 85, 247, 0.6)';
  
  return (
    <motion.div 
      className="flex items-center gap-4"
      whileHover={{ x: 4 }}
      transition={{ type: "spring", stiffness: 300 }}
    >
      <motion.div 
        className={`w-12 h-12 rounded-full bg-gradient-to-br ${color} flex items-center justify-center`}
        style={{
          boxShadow: `0 0 25px ${glowColor}, 0 0 50px ${glowColor}40, inset 0 0 15px rgba(255,255,255,0.2)`
        }}
        whileHover={{ scale: 1.1, rotate: 5 }}
        transition={{ type: "spring", stiffness: 400 }}
      >
        {icon}
      </motion.div>
      <div className="flex-1">
        <div className="text-white text-[15px]">{label}</div>
      </div>
      <div className="text-white text-[16px] tracking-tight">{amount}</div>
    </motion.div>
  );
}

function WeeklySummaryFlow({ step, onNext, onClose }: { step: number; onNext: () => void; onClose: () => void }) {
  const summaryData = [
    {
      title: "Your Top Category",
      subtitle: "You spent the most on",
      value: "Housing",
      amount: "200 €",
      emoji: "🏠",
      gradient: "from-[#E8A87C] to-[#D4886A]"
    },
    {
      title: "Biggest Transaction",
      subtitle: "Your largest expense was",
      value: "Rent",
      amount: "200 €",
      emoji: "💰",
      gradient: "from-[#C29FBD] to-[#9B7EBD]"
    },
    {
      title: "Money Saved",
      subtitle: "You saved this week",
      value: "You're doing great!",
      amount: "760 €",
      emoji: "🐷",
      gradient: "from-[#7BC9A6] to-[#5BA98A]"
    },
    {
      title: "Weekly Total",
      subtitle: "Total spending this week",
      value: "3 transactions",
      amount: "240 €",
      emoji: "📊",
      gradient: "from-[#6BB5C8] to-[#4A90A4]"
    }
  ];

  const currentData = summaryData[step] || summaryData[summaryData.length - 1];
  const isLastStep = step >= summaryData.length - 1;

  return (
    <motion.div 
      className="min-h-screen bg-gradient-to-b from-[#1A2332] via-[#2C3E50] to-[#1A2332] flex items-center justify-center p-6"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
    >
      <motion.div 
        className={`max-w-md w-full bg-gradient-to-br ${currentData.gradient} rounded-[2.5rem] p-10 border border-white/20 relative overflow-hidden`}
        initial={{ scale: 0.9, y: 20 }}
        animate={{ scale: 1, y: 0 }}
        key={step}
        transition={{ type: "spring" }}
      >
        <motion.button 
          onClick={onClose}
          className="absolute top-6 right-6 text-white/80 hover:text-white"
          whileHover={{ scale: 1.1, rotate: 90 }}
          whileTap={{ scale: 0.95 }}
        >
          <X size={24} />
        </motion.button>

        {/* Decorative emoji */}
        <motion.div 
          className="text-8xl mb-6 text-center opacity-90"
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ type: "spring", delay: 0.2 }}
        >
          {currentData.emoji}
        </motion.div>

        <div className="text-white text-center mb-8">
          <motion.div 
            className="text-[32px] mb-3 leading-tight"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
          >
            {currentData.title}
          </motion.div>
          <motion.div 
            className="text-white/80 text-[15px] mb-4"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
          >
            {currentData.subtitle}
          </motion.div>
          <motion.div 
            className="text-[48px] mb-2"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.5, type: "spring" }}
          >
            {currentData.amount}
          </motion.div>
          <motion.div 
            className="text-white/90 text-[18px]"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6 }}
          >
            {currentData.value}
          </motion.div>
        </div>

        <motion.button 
          onClick={isLastStep ? onClose : onNext}
          className="w-full bg-black/40 backdrop-blur-sm text-white py-4 rounded-2xl tracking-wider"
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7 }}
        >
          {isLastStep ? 'Done' : 'Continue'}
        </motion.button>
        
        {/* Progress dots */}
        <div className="flex justify-center gap-2 mt-6">
          {summaryData.map((_, idx) => (
            <motion.div
              key={idx}
              className={`h-2 rounded-full transition-all ${
                idx === step ? 'w-8 bg-white' : 'w-2 bg-white/40'
              }`}
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.8 + idx * 0.1 }}
            />
          ))}
        </div>
      </motion.div>
    </motion.div>
  );
}

function NewTransactionModal({ 
  onClose, 
  onOpenCategories, 
  onSave, 
  selectedCategory,
  categories 
}: { 
  onClose: () => void; 
  onOpenCategories: () => void; 
  onSave: (transaction: Transaction) => void;
  selectedCategory: { name: string; key: string };
  categories: typeof DEFAULT_CATEGORIES;
}) {
  const [transactionType, setTransactionType] = useState<'expense' | 'income' | 'transfer'>('expense');
  const [amount, setAmount] = useState('0');
  const [excludeFromBudget, setExcludeFromBudget] = useState(false);
  const [note, setNote] = useState('');
  const [isEditingAmount, setIsEditingAmount] = useState(false);
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [showDatePicker, setShowDatePicker] = useState(false);

  const handleAmountChange = (value: string) => {
    const cleaned = value.replace(/^0+/, '') || '0';
    setAmount(cleaned);
  };

  const handleSave = () => {
    const transaction: Transaction = {
      id: Date.now().toString(),
      type: transactionType,
      amount: parseFloat(amount),
      category: selectedCategory.name,
      categoryKey: selectedCategory.key,
      note: note,
      date: selectedDate,
      excludeFromBudget: excludeFromBudget
    };
    onSave(transaction);
  };

  const formatDate = (date: Date) => {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday';
    } else {
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return `${days[date.getDay()]}, ${String(date.getDate()).padStart(2, '0')} ${months[date.getMonth()]}`;
    }
  };

  const categoryData = categories[selectedCategory.key as keyof typeof categories];

  return (
    <>
      <motion.div 
        className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
        onClick={onClose}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
      />

      <motion.div 
        className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] max-w-md bg-[#2C3E50] rounded-3xl shadow-2xl z-50 max-h-[80vh] overflow-y-auto"
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.9 }}
        transition={{ type: "spring", stiffness: 300, damping: 30 }}
      >
        <div className="h-2 bg-gradient-to-r from-[#E8A87C] via-[#C29FBD] to-[#4A90A4] rounded-t-3xl"></div>
        
        <div className="flex items-center justify-between px-6 py-4">
          <motion.button 
            onClick={onClose} 
            className="text-white/70 hover:text-white transition-colors"
            whileHover={{ scale: 1.1, rotate: 90 }}
            whileTap={{ scale: 0.95 }}
          >
            <X size={24} />
          </motion.button>
          <h1 className="text-white text-[18px]">New transaction</h1>
          <div className="w-6"></div>
        </div>

        <div className="flex items-center justify-center py-8">
          {isEditingAmount ? (
            <input
              type="number"
              value={amount}
              onChange={(e) => handleAmountChange(e.target.value)}
              onBlur={() => setIsEditingAmount(false)}
              autoFocus
              className="text-white text-[56px] tracking-tight bg-transparent border-b-2 border-white/20 outline-none text-center w-56"
            />
          ) : (
            <motion.button 
              onClick={() => setIsEditingAmount(true)}
              className="text-white text-[56px] tracking-tight"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              {amount} €
            </motion.button>
          )}
        </div>

        <div className="flex gap-3 px-6 mb-6 justify-center">
          <motion.button
            onClick={() => setTransactionType('expense')}
            className={`px-5 py-2 rounded-full text-xs tracking-wider transition-all ${
              transactionType === 'expense' ? 'bg-[#395587] text-white' : 'text-white/50 hover:text-white/80'
            }`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            EXPENSE
          </motion.button>
          <motion.button
            onClick={() => setTransactionType('income')}
            className={`px-5 py-2 rounded-full text-xs tracking-wider transition-all ${
              transactionType === 'income' ? 'bg-[#395587] text-white' : 'text-white/50 hover:text-white/80'
            }`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            INCOME
          </motion.button>
          <motion.button
            onClick={() => setTransactionType('transfer')}
            className={`px-5 py-2 rounded-full text-xs tracking-wider transition-all ${
              transactionType === 'transfer' ? 'bg-[#395587] text-white' : 'text-white/50 hover:text-white/80'
            }`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            TRANSFER
          </motion.button>
        </div>

        <div className="px-6 space-y-3 pb-24">
          <motion.button 
            onClick={onOpenCategories}
            className="w-full flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl hover:bg-[#34495E]/70 transition-all"
            whileHover={{ x: 4 }}
            whileTap={{ scale: 0.98 }}
          >
            <div className={`w-10 h-10 rounded-full bg-gradient-to-br ${categoryData?.color || 'from-[#6B7C8F] to-[#4A5C6F]'} flex items-center justify-center`}>
              <span className="text-xl">{categoryData?.icon || '📦'}</span>
            </div>
            <div className="flex-1 text-left">
              <div className="text-white/50 text-xs">Category:</div>
              <div className="text-white text-[15px]">{selectedCategory.name}</div>
            </div>
          </motion.button>

          <motion.div 
            className="flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl"
            whileHover={{ x: 4 }}
          >
            <div className="w-10 h-10 flex items-center justify-center text-white/50">
              <span className="text-xl">📝</span>
            </div>
            <input 
              type="text" 
              placeholder="Note" 
              value={note}
              onChange={(e) => setNote(e.target.value)}
              className="flex-1 bg-transparent text-white placeholder:text-white/30 outline-none text-[15px]"
            />
          </motion.div>

          <motion.button 
            onClick={() => setShowDatePicker(!showDatePicker)}
            className="w-full flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl hover:bg-[#34495E]/70 transition-all"
            whileHover={{ x: 4 }}
            whileTap={{ scale: 0.98 }}
          >
            <div className="w-10 h-10 flex items-center justify-center text-white/50">
              <CalendarIcon size={20} />
            </div>
            <div className="flex-1 text-left text-white text-[15px]">{formatDate(selectedDate)}</div>
          </motion.button>

          <AnimatePresence>
            {showDatePicker && (
              <motion.div 
                className="bg-[#34495E]/50 rounded-2xl p-4"
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                transition={{ duration: 0.2 }}
              >
                <Calendar
                  mode="single"
                  selected={selectedDate}
                  onSelect={(date) => {
                    if (date) {
                      setSelectedDate(date);
                      setShowDatePicker(false);
                    }
                  }}
                  className="rounded-md"
                />
              </motion.div>
            )}
          </AnimatePresence>

          <motion.div 
            className="flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl"
            whileHover={{ x: 4 }}
          >
            <div className="w-10 h-10 flex items-center justify-center text-white/50">
              <Moon size={20} />
            </div>
            <div className="flex-1 text-white text-[15px]">Exclude from budget</div>
            <motion.button 
              onClick={() => setExcludeFromBudget(!excludeFromBudget)}
              className={`w-12 h-7 rounded-full transition-all ${
                excludeFromBudget ? 'bg-[#E8A87C]' : 'bg-[#4A5C6F]'
              }`}
              whileTap={{ scale: 0.95 }}
            >
              <motion.div 
                className="w-5 h-5 bg-white rounded-full mt-1"
                animate={{ x: excludeFromBudget ? 24 : 4 }}
                transition={{ type: "spring", stiffness: 500, damping: 30 }}
              />
            </motion.button>
          </motion.div>
        </div>

        <div className="fixed bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-[#2C3E50] via-[#2C3E50] to-transparent">
          <motion.button 
            onClick={handleSave}
            disabled={parseFloat(amount) === 0}
            className="w-full max-w-md mx-auto block bg-gradient-to-r from-[#E8A87C] to-[#D4886A] text-white py-4 rounded-full shadow-xl tracking-wider disabled:opacity-50 disabled:cursor-not-allowed"
            whileHover={{ scale: 1.02, boxShadow: "0 20px 40px rgba(232, 168, 124, 0.3)" }}
            whileTap={{ scale: 0.98 }}
            transition={{ type: "spring", stiffness: 400 }}
          >
            SAVE
          </motion.button>
        </div>
      </motion.div>
    </>
  );
}

function EditTransactionModal({ 
  onClose, 
  onOpenCategories, 
  onSave, 
  transaction,
  categories 
}: { 
  onClose: () => void; 
  onOpenCategories: () => void; 
  onSave: (transaction: Transaction) => void;
  transaction: PendingTransaction;
  categories: typeof DEFAULT_CATEGORIES;
}) {
  const [transactionType, setTransactionType] = useState<'expense' | 'income' | 'transfer'>(transaction.type);
  const [amount, setAmount] = useState(transaction.amount.toString());
  const [excludeFromBudget, setExcludeFromBudget] = useState(transaction.excludeFromBudget);
  const [note, setNote] = useState(transaction.note || transaction.description || '');
  const [isEditingAmount, setIsEditingAmount] = useState(false);
  const [selectedDate, setSelectedDate] = useState<Date>(transaction.date);
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState({ name: transaction.category, key: transaction.categoryKey });

  const handleAmountChange = (value: string) => {
    const cleaned = value.replace(/^0+/, '') || '0';
    setAmount(cleaned);
  };

  const handleSave = () => {
    const updatedTransaction: Transaction = {
      id: transaction.id,
      type: transactionType,
      amount: parseFloat(amount),
      category: selectedCategory.name,
      categoryKey: selectedCategory.key,
      note: note,
      date: selectedDate,
      excludeFromBudget: excludeFromBudget
    };
    onSave(updatedTransaction);
  };

  const formatDate = (date: Date) => {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday';
    } else {
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return `${days[date.getDay()]}, ${String(date.getDate()).padStart(2, '0')} ${months[date.getMonth()]}`;
    }
  };

  const categoryData = categories[selectedCategory.key as keyof typeof categories];

  return (
    <>
      <motion.div 
        className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
        onClick={onClose}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
      />

      <motion.div 
        className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] max-w-md bg-[#2C3E50] rounded-3xl shadow-2xl z-50 max-h-[80vh] overflow-y-auto"
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.9 }}
        transition={{ type: "spring", stiffness: 300, damping: 30 }}
      >
        <div className="h-2 bg-gradient-to-r from-[#E8A87C] via-[#C29FBD] to-[#4A90A4] rounded-t-3xl"></div>
        
        <div className="flex items-center justify-between px-6 py-4">
          <motion.button 
            onClick={onClose} 
            className="text-white/70 hover:text-white transition-colors"
            whileHover={{ scale: 1.1, rotate: 90 }}
            whileTap={{ scale: 0.95 }}
          >
            <X size={24} />
          </motion.button>
          <h1 className="text-white text-[18px]">Edit transaction</h1>
          <div className="w-6"></div>
        </div>

        <div className="flex items-center justify-center py-8">
          {isEditingAmount ? (
            <input
              type="number"
              value={amount}
              onChange={(e) => handleAmountChange(e.target.value)}
              onBlur={() => setIsEditingAmount(false)}
              autoFocus
              className="text-white text-[56px] tracking-tight bg-transparent border-b-2 border-white/20 outline-none text-center w-56"
            />
          ) : (
            <motion.button 
              onClick={() => setIsEditingAmount(true)}
              className="text-white text-[56px] tracking-tight"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              {amount} €
            </motion.button>
          )}
        </div>

        <div className="flex gap-3 px-6 mb-6 justify-center">
          <motion.button
            onClick={() => setTransactionType('expense')}
            className={`px-5 py-2 rounded-full text-xs tracking-wider transition-all ${
              transactionType === 'expense' ? 'bg-[#395587] text-white' : 'text-white/50 hover:text-white/80'
            }`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            EXPENSE
          </motion.button>
          <motion.button
            onClick={() => setTransactionType('income')}
            className={`px-5 py-2 rounded-full text-xs tracking-wider transition-all ${
              transactionType === 'income' ? 'bg-[#395587] text-white' : 'text-white/50 hover:text-white/80'
            }`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            INCOME
          </motion.button>
          <motion.button
            onClick={() => setTransactionType('transfer')}
            className={`px-5 py-2 rounded-full text-xs tracking-wider transition-all ${
              transactionType === 'transfer' ? 'bg-[#395587] text-white' : 'text-white/50 hover:text-white/80'
            }`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            TRANSFER
          </motion.button>
        </div>

        <div className="px-6 space-y-3 pb-24">
          <motion.button 
            onClick={onOpenCategories}
            className="w-full flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl hover:bg-[#34495E]/70 transition-all"
            whileHover={{ x: 4 }}
            whileTap={{ scale: 0.98 }}
          >
            <div className={`w-10 h-10 rounded-full bg-gradient-to-br ${categoryData?.color || 'from-[#6B7C8F] to-[#4A5C6F]'} flex items-center justify-center`}>
              <span className="text-xl">{categoryData?.icon || '📦'}</span>
            </div>
            <div className="flex-1 text-left">
              <div className="text-white/50 text-xs">Category:</div>
              <div className="text-white text-[15px]">{selectedCategory.name}</div>
            </div>
          </motion.button>

          <motion.div 
            className="flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl"
            whileHover={{ x: 4 }}
          >
            <div className="w-10 h-10 flex items-center justify-center text-white/50">
              <span className="text-xl">📝</span>
            </div>
            <input 
              type="text" 
              placeholder="Note" 
              value={note}
              onChange={(e) => setNote(e.target.value)}
              className="flex-1 bg-transparent text-white placeholder:text-white/30 outline-none text-[15px]"
            />
          </motion.div>

          <motion.button 
            onClick={() => setShowDatePicker(!showDatePicker)}
            className="w-full flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl hover:bg-[#34495E]/70 transition-all"
            whileHover={{ x: 4 }}
            whileTap={{ scale: 0.98 }}
          >
            <div className="w-10 h-10 flex items-center justify-center text-white/50">
              <CalendarIcon size={20} />
            </div>
            <div className="flex-1 text-left text-white text-[15px]">{formatDate(selectedDate)}</div>
          </motion.button>

          <AnimatePresence>
            {showDatePicker && (
              <motion.div 
                className="bg-[#34495E]/50 rounded-2xl p-4"
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                transition={{ duration: 0.2 }}
              >
                <Calendar
                  mode="single"
                  selected={selectedDate}
                  onSelect={(date) => {
                    if (date) {
                      setSelectedDate(date);
                      setShowDatePicker(false);
                    }
                  }}
                  className="rounded-md"
                />
              </motion.div>
            )}
          </AnimatePresence>

          <motion.div 
            className="flex items-center gap-3 p-3 bg-[#34495E]/50 rounded-2xl"
            whileHover={{ x: 4 }}
          >
            <div className="w-10 h-10 flex items-center justify-center text-white/50">
              <Moon size={20} />
            </div>
            <div className="flex-1 text-white text-[15px]">Exclude from budget</div>
            <motion.button 
              onClick={() => setExcludeFromBudget(!excludeFromBudget)}
              className={`w-12 h-7 rounded-full transition-all ${
                excludeFromBudget ? 'bg-[#E8A87C]' : 'bg-[#4A5C6F]'
              }`}
              whileTap={{ scale: 0.95 }}
            >
              <motion.div 
                className="w-5 h-5 bg-white rounded-full mt-1"
                animate={{ x: excludeFromBudget ? 24 : 4 }}
                transition={{ type: "spring", stiffness: 500, damping: 30 }}
              />
            </motion.button>
          </motion.div>
        </div>

        <div className="fixed bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-[#2C3E50] via-[#2C3E50] to-transparent">
          <motion.button 
            onClick={handleSave}
            disabled={parseFloat(amount) === 0}
            className="w-full max-w-md mx-auto block bg-gradient-to-r from-[#E8A87C] to-[#D4886A] text-white py-4 rounded-full shadow-xl tracking-wider disabled:opacity-50 disabled:cursor-not-allowed"
            whileHover={{ scale: 1.02, boxShadow: "0 20px 40px rgba(232, 168, 124, 0.3)" }}
            whileTap={{ scale: 0.98 }}
            transition={{ type: "spring", stiffness: 400 }}
          >
            SAVE
          </motion.button>
        </div>
      </motion.div>
    </>
  );
}

function CategoryPickerScreen({ 
  onClose, 
  onSelect, 
  categories,
  onAddSubcategory,
  onDeleteSubcategory 
}: { 
  onClose: () => void; 
  onSelect: (name: string, key: string) => void;
  categories: typeof DEFAULT_CATEGORIES;
  onAddSubcategory: (categoryKey: string, subcategoryName: string) => void;
  onDeleteSubcategory: (categoryKey: string, subcategoryName: string) => void;
}) {
  const [expandedCategory, setExpandedCategory] = useState<string | null>(null);
  const [isAddingSubcategory, setIsAddingSubcategory] = useState(false);
  const [newSubcategoryName, setNewSubcategoryName] = useState('');

  const handleAddSubcategory = () => {
    if (newSubcategoryName.trim() && expandedCategory) {
      onAddSubcategory(expandedCategory, newSubcategoryName.trim());
      setNewSubcategoryName('');
      setIsAddingSubcategory(false);
    }
  };

  return (
    <motion.div 
      className="min-h-screen bg-gradient-to-b from-[#1A2332] via-[#2C3E50] to-[#1A2332] pb-20"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
    >
      <div className="bg-gradient-to-r from-[#395587] via-[#4A6BA3] to-[#5C7A9B] px-6 py-4">
        <div className="flex items-center justify-between">
          <motion.button 
            onClick={onClose}
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.95 }}
          >
            <ChevronLeft className="text-white" size={24} />
          </motion.button>
          <h1 className="text-white text-[18px]">Select Category</h1>
          <div className="w-6"></div>
        </div>
      </div>

      <div className="px-4 pt-6 max-w-[480px] mx-auto">
        <div className="space-y-3">
          {Object.entries(categories).map(([key, category], idx) => (
            <motion.div 
              key={key}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.05 }}
            >
              <motion.button
                onClick={() => {
                  if (expandedCategory === key) {
                    setExpandedCategory(null);
                  } else {
                    setExpandedCategory(key);
                  }
                }}
                className="w-full flex items-center gap-3 p-4 bg-[#2C3E50]/90 rounded-2xl border border-white/10"
                whileHover={{ x: 4 }}
                whileTap={{ scale: 0.98 }}
              >
                <div className={`w-12 h-12 rounded-full bg-gradient-to-br ${category.color} flex items-center justify-center`}>
                  <span className="text-2xl">{category.icon}</span>
                </div>
                <div className="flex-1 text-left text-white text-[16px]">{category.name}</div>
                <motion.div
                  animate={{ rotate: expandedCategory === key ? 180 : 0 }}
                  transition={{ duration: 0.2 }}
                >
                  <ChevronRight className="text-white/40" size={20} />
                </motion.div>
              </motion.button>

              <AnimatePresence>
                {expandedCategory === key && (
                  <motion.div
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: "auto" }}
                    exit={{ opacity: 0, height: 0 }}
                    transition={{ duration: 0.2 }}
                    className="mt-2 ml-4 space-y-2"
                  >
                    {category.subcategories.map((sub, subIdx) => (
                      <motion.div
                        key={sub}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: subIdx * 0.05 }}
                        className="flex items-center gap-2"
                      >
                        <motion.button
                          onClick={() => onSelect(sub, key)}
                          className="flex-1 p-3 bg-[#34495E]/50 rounded-xl text-white text-[14px] text-left"
                          whileHover={{ x: 4 }}
                          whileTap={{ scale: 0.98 }}
                        >
                          {sub}
                        </motion.button>
                        <motion.button
                          onClick={() => onDeleteSubcategory(key, sub)}
                          className="p-3 bg-[#34495E]/50 rounded-xl text-red-400"
                          whileHover={{ scale: 1.1 }}
                          whileTap={{ scale: 0.95 }}
                        >
                          <Trash2 size={16} />
                        </motion.button>
                      </motion.div>
                    ))}
                    
                    {isAddingSubcategory ? (
                      <motion.div 
                        className="flex gap-2"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                      >
                        <input
                          type="text"
                          value={newSubcategoryName}
                          onChange={(e) => setNewSubcategoryName(e.target.value)}
                          onKeyDown={(e) => e.key === 'Enter' && handleAddSubcategory()}
                          placeholder="New subcategory"
                          className="flex-1 p-3 bg-[#34495E]/50 rounded-xl text-white text-[14px] outline-none"
                          autoFocus
                        />
                        <motion.button
                          onClick={handleAddSubcategory}
                          className="p-3 bg-[#E8A87C] rounded-xl text-white"
                          whileHover={{ scale: 1.1 }}
                          whileTap={{ scale: 0.95 }}
                        >
                          <Plus size={16} />
                        </motion.button>
                      </motion.div>
                    ) : (
                      <motion.button
                        onClick={() => setIsAddingSubcategory(true)}
                        className="w-full p-3 bg-[#34495E]/30 rounded-xl text-white/50 text-[14px] text-left flex items-center gap-2"
                        whileHover={{ x: 4, backgroundColor: "rgba(52, 73, 94, 0.5)" }}
                        whileTap={{ scale: 0.98 }}
                      >
                        <Plus size={16} />
                        Add subcategory
                      </motion.button>
                    )}
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </div>
      </div>
    </motion.div>
  );
}

function CardConnectionModal({ 
  onClose, 
  onConnect,
  isConnected
}: { 
  onClose: () => void;
  onConnect: () => void;
  isConnected: boolean;
}) {
  const [cardNumber, setCardNumber] = useState('');
  const [isConnecting, setIsConnecting] = useState(false);

  const handleConnect = () => {
    setIsConnecting(true);
    setTimeout(() => {
      onConnect();
      setIsConnecting(false);
    }, 1500);
  };

  return (
    <>
      <motion.div 
        className="fixed inset-0 bg-black/70 backdrop-blur-md z-50"
        onClick={onClose}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
      />
      
      <motion.div 
        className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] max-w-md bg-gradient-to-br from-[#2C3E50] via-[#34495E] to-[#2C3E50] rounded-3xl shadow-2xl z-50 border border-white/20"
        initial={{ opacity: 0, scale: 0.8, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.8, y: 20 }}
        transition={{ type: "spring", stiffness: 300, damping: 30 }}
      >
        <div className="h-2 bg-gradient-to-r from-[#C29FBD] via-[#9B7EBD] to-[#C29FBD] rounded-t-3xl"></div>
        
        <div className="p-8">
          <motion.button 
            onClick={onClose}
            className="absolute top-6 right-6 text-white/60 hover:text-white"
            whileHover={{ scale: 1.1, rotate: 90 }}
            whileTap={{ scale: 0.95 }}
          >
            <X size={24} />
          </motion.button>

          <motion.div 
            className="flex items-center justify-center mb-6"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", delay: 0.2 }}
          >
            <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[#C29FBD] to-[#9B7EBD] flex items-center justify-center shadow-xl">
              <CreditCard className="text-white" size={40} />
            </div>
          </motion.div>

          <motion.h2 
            className="text-white text-[24px] text-center mb-3"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
          >
            Connect Your Card
          </motion.h2>
          
          <motion.p 
            className="text-white/60 text-center mb-8 text-[14px]"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
          >
            Link your bank card to automatically import transactions
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
          >
            <div className="mb-6">
              <label className="text-white/70 text-[12px] tracking-wider uppercase mb-2 block">Card Number</label>
              <input
                type="text"
                value={cardNumber}
                onChange={(e) => setCardNumber(e.target.value)}
                placeholder="•••• •••• •••• ••••"
                className="w-full p-4 bg-[#1A2332]/50 rounded-2xl text-white placeholder:text-white/30 outline-none border border-white/10 focus:border-[#C29FBD] transition-colors"
                maxLength={19}
              />
            </div>

            <motion.button
              onClick={handleConnect}
              disabled={isConnecting}
              className="w-full bg-gradient-to-r from-[#C29FBD] to-[#9B7EBD] text-white py-4 rounded-2xl tracking-wider disabled:opacity-50 flex items-center justify-center gap-2"
              whileHover={{ scale: 1.02, boxShadow: "0 20px 40px rgba(194, 159, 189, 0.3)" }}
              whileTap={{ scale: 0.98 }}
            >
              {isConnecting ? (
                <>
                  <motion.div
                    className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full"
                    animate={{ rotate: 360 }}
                    transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  />
                  Connecting...
                </>
              ) : (
                <>
                  <Check size={20} />
                  CONNECT CARD
                </>
              )}
            </motion.button>
          </motion.div>
        </div>
      </motion.div>
    </>
  );
}

function TransactionCardSwiper({
  transactions,
  onSwipeRight,
  onSwipeLeft,
  onClose,
  categories
}: {
  transactions: PendingTransaction[];
  onSwipeRight: (transaction: PendingTransaction) => void;
  onSwipeLeft: (transaction: PendingTransaction) => void;
  onClose: () => void;
  categories: typeof DEFAULT_CATEGORIES;
}) {
  const [currentIndex, setCurrentIndex] = useState(0);

  const currentTransaction = transactions[currentIndex];
  
  if (!currentTransaction) {
    return (
      <>
        <motion.div 
          className="fixed inset-0 bg-black/70 backdrop-blur-md z-50"
          onClick={onClose}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        />
        
        <motion.div 
          className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] max-w-md bg-gradient-to-br from-[#2C3E50] via-[#34495E] to-[#2C3E50] rounded-3xl shadow-2xl z-50 border border-white/20 p-12"
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.8 }}
        >
          <div className="text-center">
            <motion.div 
              className="w-20 h-20 rounded-full bg-gradient-to-br from-[#7BC9A6] to-[#5BA98A] flex items-center justify-center mx-auto mb-6"
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: "spring" }}
            >
              <Check className="text-white" size={40} />
            </motion.div>
            <div className="text-white text-[24px] mb-4">All Done!</div>
            <div className="text-white/60 text-[14px] mb-8">You've reviewed all pending transactions</div>
            <motion.button
              onClick={onClose}
              className="w-full bg-gradient-to-r from-[#E8A87C] to-[#D4886A] text-white py-4 rounded-2xl tracking-wider"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              CLOSE
            </motion.button>
          </div>
        </motion.div>
      </>
    );
  }

  const categoryData = categories[currentTransaction.categoryKey as keyof typeof categories];

  const handleDragEnd = (event: any, info: any) => {
    const threshold = 100;
    
    if (info.offset.x > threshold) {
      onSwipeRight(currentTransaction);
      setCurrentIndex(prev => prev + 1);
    } else if (info.offset.x < -threshold) {
      onSwipeLeft(currentTransaction);
      setCurrentIndex(prev => prev + 1);
    }
  };

  return (
    <>
      <motion.div 
        className="fixed inset-0 bg-black/70 backdrop-blur-md z-50"
        onClick={onClose}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
      />

      <div className="fixed inset-0 z-50 flex items-center justify-center p-6 pointer-events-none">
        <div className="relative w-full max-w-md h-[500px] pointer-events-auto">
          <motion.div 
            className="absolute -top-20 left-0 right-0 flex justify-between px-4"
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
          >
            <div className="flex items-center gap-2 text-white/60 text-[13px]">
              <div className="w-8 h-8 rounded-full bg-red-500/20 flex items-center justify-center">
                <Edit size={16} className="text-red-400" />
              </div>
              Swipe left to edit
            </div>
            <div className="flex items-center gap-2 text-white/60 text-[13px]">
              Swipe right to add
              <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center">
                <Check size={16} className="text-green-400" />
              </div>
            </div>
          </motion.div>

          {transactions.slice(currentIndex + 1, currentIndex + 3).reverse().map((transaction, idx) => (
            <motion.div
              key={transaction.id}
              className="absolute inset-0 bg-gradient-to-br from-[#2C3E50] via-[#34495E] to-[#2C3E50] rounded-3xl border border-white/20"
              style={{
                zIndex: -idx - 1,
              }}
              initial={{ scale: 1 - (idx + 1) * 0.05, y: (idx + 1) * 10 }}
              animate={{ scale: 1 - (idx + 1) * 0.05, y: (idx + 1) * 10 }}
            />
          ))}

          <motion.div
            drag="x"
            dragConstraints={{ left: 0, right: 0 }}
            onDragEnd={handleDragEnd}
            className="absolute inset-0 cursor-grab active:cursor-grabbing"
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            <motion.div 
              className="w-full h-full bg-gradient-to-br from-[#2C3E50] via-[#34495E] to-[#2C3E50] rounded-3xl shadow-2xl border border-white/20 p-8 flex flex-col"
              whileHover={{ scale: 1.02 }}
            >
              <div className="flex items-center justify-between mb-6">
                <motion.div 
                  className={`w-16 h-16 rounded-2xl bg-gradient-to-br ${categoryData?.color || 'from-[#6B7C8F] to-[#4A5C6F]'} flex items-center justify-center shadow-lg`}
                  whileHover={{ rotate: 5, scale: 1.1 }}
                  transition={{ type: "spring" }}
                >
                  <span className="text-3xl">{categoryData?.icon || '📦'}</span>
                </motion.div>
                <div className="text-right">
                  <div className="text-white/50 text-[11px] tracking-wider uppercase">Amount</div>
                  <div className="text-white text-[32px] tracking-tight">-{currentTransaction.amount.toFixed(2)} €</div>
                </div>
              </div>

              <div className="mb-4">
                <div className="text-white/50 text-[11px] tracking-wider uppercase mb-1">Merchant</div>
                <div className="text-white text-[20px]">{currentTransaction.merchant || 'Unknown'}</div>
              </div>

              <div className="mb-4">
                <div className="text-white/50 text-[11px] tracking-wider uppercase mb-1">Description</div>
                <div className="text-white text-[16px]">{currentTransaction.description || currentTransaction.note}</div>
              </div>

              <div className="mb-4">
                <div className="text-white/50 text-[11px] tracking-wider uppercase mb-1">Category</div>
                <div className="flex items-center gap-2">
                  <div className={`px-4 py-2 rounded-full bg-gradient-to-r ${categoryData?.color || 'from-[#6B7C8F] to-[#4A5C6F]'}`}>
                    <span className="text-white text-[13px]">{currentTransaction.category}</span>
                  </div>
                </div>
              </div>

              <div className="mt-auto">
                <div className="text-white/50 text-[11px] tracking-wider uppercase mb-1">Date</div>
                <div className="text-white text-[14px]">{currentTransaction.date.toLocaleDateString('en-US', { 
                  weekday: 'long', 
                  year: 'numeric', 
                  month: 'long', 
                  day: 'numeric' 
                })}</div>
              </div>

              <div className="absolute top-6 right-6 px-3 py-1 rounded-full bg-white/10 backdrop-blur-sm">
                <span className="text-white/60 text-[12px]">{currentIndex + 1} / {transactions.length}</span>
              </div>
            </motion.div>
          </motion.div>

          <motion.button
            onClick={onClose}
            className="absolute -bottom-16 left-1/2 -translate-x-1/2 text-white/60 hover:text-white text-[13px] tracking-wider uppercase"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Close
          </motion.button>
        </div>
      </div>
    </>
  );
}
