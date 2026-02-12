/**
 * Format decimal degrees to DMS (Degrees Minutes Seconds) string.
 * Example: formatDMS(43.835278, true) => "N 43° 50' 7\""
 */
export function formatDMS(decimal, isLatitude) {
  const direction = isLatitude
    ? decimal >= 0 ? 'N' : 'S'
    : decimal >= 0 ? 'E' : 'W';
  const abs = Math.abs(decimal);
  const degrees = Math.floor(abs);
  const minutesDecimal = (abs - degrees) * 60;
  const minutes = Math.floor(minutesDecimal);
  const seconds = Math.floor((minutesDecimal - minutes) * 60);
  return `${direction} ${degrees}\u00B0 ${minutes}' ${seconds}"`;
}

/**
 * Get cardinal direction string from heading degrees.
 * Example: cardinalDirection(274) => "W"
 */
export function cardinalDirection(degrees) {
  const directions = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
  ];
  const index = Math.round(degrees / 22.5) % 16;
  return directions[index];
}

/**
 * Format a Date to display string.
 * Example: "Feb 7, 2026 at 12:09:05 PM"
 */
export function formatDateTime(date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  const month = months[date.getMonth()];
  const day = date.getDate();
  const year = date.getFullYear();

  let hours = date.getHours();
  const ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12 || 12;

  const minutes = String(date.getMinutes()).padStart(2, '0');
  const seconds = String(date.getSeconds()).padStart(2, '0');

  return `${month} ${day}, ${year} at ${hours}:${minutes}:${seconds} ${ampm}`;
}
