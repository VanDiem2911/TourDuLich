import { Link } from 'react-router-dom'
import { money, fmtDayMonth } from '../utils/format'

export default function TourCard({ tour }) {
  const low = tour.availableSeats > 0 && tour.availableSeats <= 5
  const soldOut = tour.availableSeats <= 0
  return (
    <Link to={`/tours/${tour.id}`} className="tour-card">
      <div className="tour-card__media">
        <img src={tour.imageUrl} alt={tour.name} loading="lazy" width="640" height="480" />
        <span className="tour-card__stamp">{tour.duration}</span>
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
            <small>từ</small>
            {money(tour.adultPrice)}
          </span>
        </div>
      </div>
    </Link>
  )
}
