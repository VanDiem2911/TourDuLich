import { Link } from 'react-router-dom'
import { money, fmtDayMonth } from '../utils/format'

export const discountPct = (t) => Math.round((100 * (t.originalPrice - t.adultPrice)) / t.originalPrice)

export default function TourCard({ tour }) {
  const low = tour.availableSeats > 0 && tour.availableSeats <= 5
  const soldOut = tour.availableSeats <= 0
  return (
    <Link to={`/tours/${tour.id}`} className="tour-card" data-track="tour-card" data-tour-id={tour.id}>
      <div className="tour-card__media">
        <img src={tour.imageUrl} alt={tour.name} loading="lazy" width="640" height="480" />
        <span className="tour-card__stamp">{tour.duration}</span>
        {tour.originalPrice > 0 && (
          <span className="tour-card__stamp tour-card__stamp--sale">Giảm {discountPct(tour)}%</span>
        )}
        {(low || soldOut) && (
          <span className="tour-card__stamp tour-card__stamp--alert">
            {soldOut ? 'Hết chỗ' : `Còn ${tour.availableSeats} chỗ`}
          </span>
        )}
      </div>
      <div className="tour-card__body">
        <span className="tour-card__where">
          {tour.departureLocation} → {tour.destination}
        </span>
        <h3>{tour.name}</h3>
        {tour.shortDescription && <p className="tour-card__desc">{tour.shortDescription}</p>}
        <div className="tour-card__foot">
          <span>
            {tour.departureDate ? `Khởi hành ${fmtDayMonth(tour.departureDate)}` : tour.transport}
            {tour.transport && tour.departureDate ? ` · ${tour.transport}` : ''}
          </span>
          <span className="price">
            {tour.originalPrice > 0 && <s className="price__old">{money(tour.originalPrice)}</s>}
            <small>từ</small>
            {money(tour.adultPrice)}
          </span>
        </div>
      </div>
    </Link>
  )
}
