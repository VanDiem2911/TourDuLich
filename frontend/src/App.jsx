import { Route, Routes } from 'react-router-dom'
import MainLayout from './layouts/MainLayout'
import AdminLayout from './layouts/AdminLayout'
import { RequireAdmin, RequireAuth } from './components/RouteGuards'
import Home from './pages/Home'
import Tours from './pages/Tours'
import TourDetail from './pages/TourDetail'
import Cart from './pages/Cart'
import Checkout from './pages/Checkout'
import BookingSuccess from './pages/BookingSuccess'
import Payment from './pages/Payment'
import MyBookings from './pages/MyBookings'
import BookingDetail from './pages/BookingDetail'
import Contact from './pages/Contact'
import Account from './pages/Account'
import Login from './pages/auth/Login'
import Register from './pages/auth/Register'
import NotFound from './pages/NotFound'
import AdminDashboard from './pages/admin/Dashboard'
import AdminTours from './pages/admin/Tours'
import AdminCategories from './pages/admin/Categories'
import AdminBookings from './pages/admin/Bookings'
import AdminUsers from './pages/admin/Users'
import AdminContacts from './pages/admin/Contacts'

export default function App() {
  return (
    <Routes>
      <Route element={<MainLayout />}>
        {/* Công khai: Guest, Customer, Admin */}
        <Route index element={<Home />} />
        <Route path="tours" element={<Tours />} />
        <Route path="tours/:id" element={<TourDetail />} />
        <Route path="cart" element={<Cart />} />
        <Route path="contact" element={<Contact />} />
        <Route path="login" element={<Login />} />
        <Route path="register" element={<Register />} />

        {/* Cần đăng nhập: Customer, Admin */}
        <Route element={<RequireAuth />}>
          <Route path="checkout" element={<Checkout />} />
          <Route path="booking-success/:id" element={<BookingSuccess />} />
          <Route path="payment/:id" element={<Payment />} />
          <Route path="my-bookings" element={<MyBookings />} />
          <Route path="my-bookings/:id" element={<BookingDetail />} />
          <Route path="account" element={<Account />} />
        </Route>

        <Route path="*" element={<NotFound />} />
      </Route>

      {/* Khu vực quản trị: chỉ ROLE_ADMIN */}
      <Route path="admin" element={<RequireAdmin />}>
        <Route element={<AdminLayout />}>
          <Route index element={<AdminDashboard />} />
          <Route path="tours" element={<AdminTours />} />
          <Route path="categories" element={<AdminCategories />} />
          <Route path="bookings" element={<AdminBookings />} />
          <Route path="users" element={<AdminUsers />} />
          <Route path="contacts" element={<AdminContacts />} />
        </Route>
      </Route>
    </Routes>
  )
}
