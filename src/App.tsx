import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from '@/components/ui/toaster';
import { AuthProvider, useAuth } from '@/hooks/auth-context';
// import { OrganizationProvider } from '@/hooks/useOrganization';
import { SplashScreen } from '@/components/mobile/SplashScreen';

// Layout
import AppLayout from './components/layout/AppLayout';

// Pages
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Clients from './pages/Clients';
import Equipment from './pages/Equipment';
import Reservations from './pages/Reservations';
import ReservationCalendarPage from './pages/ReservationCalendarPage';
import EquipmentReturn from './pages/EquipmentReturn';
import Finance from './pages/Finance';
import GestionSimple from './pages/GestionSimple';
import Statistics from './pages/Statistics';
import Kits from './pages/Kits';
import ReservationLinks from './pages/ReservationLinks';
import ReservationLinksSimple from './pages/ReservationLinksSimple';
import CreancesPage from './pages/CreancesPage';
import TestSupabase from './pages/TestSupabase';
import PublicReservation from './pages/PublicReservation';
import Settings from './pages/Settings';
import UserManagement from './pages/UserManagement';
import TelegramSetupPage from './pages/TelegramSetupPage';
import NotFound from './pages/NotFound';
import Index from './pages/Index';
import Onboarding from './pages/Onboarding';
import Pricing from './pages/Pricing';
import AdminSetup from './pages/AdminSetup';
import QuickAdminLogin from './pages/QuickAdminLogin';
import ResetPassword from './pages/ResetPassword';
import Apporteurs from './pages/Apporteurs';
import Charges from './pages/Charges';
import Paie from './pages/Paie';
import Investments from './pages/Investments';
import AIAssistant from './pages/AIAssistant';
import SalesPage from './pages/SalesPage';
import TestDashboard from './pages/TestDashboard';

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

// Route Guard for authenticated users
const ProtectedRoute: React.FC<{ element: React.ReactNode }> = ({ element }) => {
  const { isAuthenticated, isLoading, profile } = useAuth();
  
  if (isLoading) {
    return <div className="h-screen flex items-center justify-center">Chargement...</div>;
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  // Temporarily disable organization check for admin setup
  // if (!(profile as any)?.organization_id) {
  //   return <Navigate to="/onboarding" />;
  // }
  
  return element;
};

// Route Guard for onboarding (requires auth but no organization)
const OnboardingRoute: React.FC<{ element: React.ReactNode }> = ({ element }) => {
  const { isAuthenticated, isLoading, profile } = useAuth();
  
  if (isLoading) {
    return <div className="h-screen flex items-center justify-center">Chargement...</div>;
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  // Temporarily disable organization check
  // if ((profile as any)?.organization_id) {
  //   return <Navigate to="/dashboard" />;
  // }
  
  return element;
};

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        {/* <OrganizationProvider> */}
        <SplashScreen>
          <Router>
            <Routes>
              {/* Public routes */}
              <Route path="/" element={<Index />} />
              <Route path="/login" element={<Login />} />
              <Route path="/reset-password" element={<ResetPassword />} />
              <Route path="/pricing" element={<Pricing />} />
              <Route path="/admin-setup" element={<AdminSetup />} />
              <Route path="/quick-admin" element={<QuickAdminLogin />} />
              <Route path="/public-reservation/:linkToken" element={<PublicReservation />} />
              
              {/* Test route - bypass all auth */}
              <Route path="/test-dashboard" element={<TestDashboard />} />
              
              {/* Onboarding route (authenticated but no organization) */}
              <Route path="/onboarding" element={<OnboardingRoute element={<Onboarding />} />} />
              
              {/* Protected routes (require organization) */}
              <Route path="/app" element={<ProtectedRoute element={<AppLayout />} />}>
                <Route path="dashboard" element={<ProtectedRoute element={<Dashboard />} />} />
                <Route path="clients" element={<ProtectedRoute element={<Clients />} />} />
                <Route path="equipment" element={<ProtectedRoute element={<Equipment />} />} />
                <Route path="reservations" element={<ProtectedRoute element={<Reservations />} />} />
                <Route path="calendar" element={<ProtectedRoute element={<ReservationCalendarPage />} />} />
                <Route path="return" element={<ProtectedRoute element={<EquipmentReturn />} />} />
                <Route path="finance" element={<Navigate to="/app/gestion" replace />} />
                <Route path="gestion" element={<ProtectedRoute element={<GestionSimple />} />} />
                <Route path="statistics" element={<ProtectedRoute element={<Statistics />} />} />
                <Route path="charges" element={<ProtectedRoute element={<Charges />} />} />
                <Route path="paie" element={<ProtectedRoute element={<Paie />} />} />
                <Route path="kits" element={<ProtectedRoute element={<Kits />} />} />
                <Route path="links" element={<ProtectedRoute element={<ReservationLinks />} />} />
                <Route path="creances" element={<ProtectedRoute element={<CreancesPage />} />} />
                <Route path="links-simple" element={<ProtectedRoute element={<ReservationLinksSimple />} />} />
                <Route path="test-supabase" element={<ProtectedRoute element={<TestSupabase />} />} />
                <Route path="telegram-setup" element={<ProtectedRoute element={<TelegramSetupPage />} />} />
                <Route path="settings" element={<ProtectedRoute element={<Settings />} />} />
                <Route path="user-management" element={<ProtectedRoute element={<UserManagement />} />} />
                <Route path="apporteurs" element={<ProtectedRoute element={<Apporteurs />} />} />
                <Route path="investments" element={<ProtectedRoute element={<Investments />} />} />
                <Route path="ai-assistant" element={<ProtectedRoute element={<AIAssistant />} />} />
                <Route path="sales" element={<ProtectedRoute element={<SalesPage />} />} />
                
                <Route path="*" element={<NotFound />} />
              </Route>

              {/* Legacy redirect */}
              <Route path="/dashboard" element={<Navigate to="/app/dashboard" replace />} />
              <Route path="/clients" element={<Navigate to="/app/clients" replace />} />
              <Route path="/equipment" element={<Navigate to="/app/equipment" replace />} />
              <Route path="/reservations" element={<Navigate to="/app/reservations" replace />} />
              <Route path="/calendar" element={<Navigate to="/app/calendar" replace />} />
              <Route path="/return" element={<Navigate to="/app/return" replace />} />
              <Route path="/finance" element={<Navigate to="/app/finance" replace />} />
              <Route path="/statistics" element={<Navigate to="/app/statistics" replace />} />
              <Route path="/charges" element={<Navigate to="/app/charges" replace />} />
              <Route path="/paie" element={<Navigate to="/app/paie" replace />} />
              <Route path="/finance" element={<Navigate to="/app/gestion" replace />} />
              <Route path="/kits" element={<Navigate to="/app/kits" replace />} />
              <Route path="/links" element={<Navigate to="/app/links" replace />} />
              <Route path="/links-simple" element={<Navigate to="/app/links-simple" replace />} />
              <Route path="/test-supabase" element={<Navigate to="/app/test-supabase" replace />} />
              <Route path="/telegram-setup" element={<Navigate to="/app/telegram-setup" replace />} />
              <Route path="/settings" element={<Navigate to="/app/settings" replace />} />
              <Route path="/user-management" element={<Navigate to="/app/user-management" replace />} />
              <Route path="/apporteurs" element={<Navigate to="/app/apporteurs" replace />} />
              <Route path="/investments" element={<Navigate to="/app/investments" replace />} />
              <Route path="/ai-assistant" element={<Navigate to="/app/ai-assistant" replace />} />
              <Route path="/sales" element={<Navigate to="/app/sales" replace />} />
              
              {/* Catch all */}
              <Route path="*" element={<NotFound />} />
            </Routes>
          </Router>
          <Toaster />
        </SplashScreen>
        {/* </OrganizationProvider> */}
      </AuthProvider>
    </QueryClientProvider>
  );
}

export default App;
