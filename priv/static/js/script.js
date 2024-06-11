document.addEventListener('DOMContentLoaded', async () => {
  const map = L.map('map').setView([37.7749, -122.4194], 13); // Set initial view

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors'
  }).addTo(map);

  // Function to load the map markers based on filters
  const loadMapMarkers = async (filters = {}) => {
    const queryString = new URLSearchParams(filters).toString();
    const response = await fetch(`/api/trucks/?${queryString}`);
    if (!response.ok) {
      console.error('Failed to fetch data:', response.statusText);
      return;
    }

    const pins = await response.json();
    let suggestion = null;

    // Clear existing markers
    map.eachLayer(layer => {
      if (layer instanceof L.Marker) {
        map.removeLayer(layer);
      }
    });

    // Define the bounding box for San Francisco
    const minLat = 37.7082;
    const maxLat = 37.8324;
    const minLng = -123.0245;
    const maxLng = -122.3575;

    // Filter pins to only include those within San Francisco's boundaries
    const filteredPins = pins.data.filter(truck =>
      truck.latitude >= minLat && truck.latitude <= maxLat &&
      truck.longitude >= minLng && truck.longitude <= maxLng
    );

    // Add new markers
    if (Array.isArray(filteredPins)) {
      const markers = filteredPins.map(truck =>
        L.marker([truck.latitude, truck.longitude])
          .bindPopup(`<b>${truck.description}</b><br>${truck.food_items}`)
      );

      // Add markers to the map
      markers.forEach(marker => marker.addTo(map));

      // Set map view to fit all markers
      if (markers.length > 0) {
        const group = new L.featureGroup(markers);
        map.fitBounds(group.getBounds());

        // Suggest a random truck
        suggestion = filteredPins[Math.floor(Math.random() * filteredPins.length)];

        // Hide all popups initially
        markers.forEach(marker => marker.closePopup());

        // Update UI based on the presence of a suggestion
        if (suggestion) {
          console.log(suggestion)
          document.querySelector('.question-mark').classList.add('d-none');
          document.querySelector('.suggestion-title').classList.remove('d-none');
          document.querySelector('.suggestion').innerHTML = `
            <p><strong>Description:</strong> ${suggestion.description}</p>
            <p><strong>Address:</strong> ${suggestion.address}</p>
            <p><strong>Food Items:</strong> ${suggestion.food_items}</p>
          `;
          document.querySelector('.suggestion').classList.remove('d-none');
        }
      }
    } else {
      console.error('Unexpected response format:', pins);
    }
  };

  // Event listener for the button
  document.querySelector('button').addEventListener('click', () => {
    const filters = {
      vegan: document.getElementById('vegan').checked ? 'true' : '',
      quick: document.getElementById('quick').checked ? 'true' : '',
      danger: document.getElementById('danger').checked ? 'true' : ''
    };
    loadMapMarkers(filters);
  });
});
