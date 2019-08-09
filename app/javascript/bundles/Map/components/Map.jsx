import React from 'react'

class Map extends React.Component {
  componentDidMount() {
    mapboxgl.accessToken = this.props.token
    let { coordinates } = this.props;
    const mapOptions = {
      container: this.mapContainer,
      style: `mapbox://styles/mapbox/streets-v9`,
      zoom: 12,
      center: coordinates
    }
    const geolocationOptions = {
      enableHighAccuracy: true,
      maximumAge        : 30000,
      timeout           : 27000
    }
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        // success callback
        (position) => {
          coordinates = [
            position.coords.longitude,
            position.coords.latitude
          ]
          mapOptions.center = coordinates
          this.createMap(mapOptions, geolocationOptions)
        },
        // failure callback
        () => { this.createMap(mapOptions, geolocationOptions) },
        // options
        geolocationOptions
      );
    }else{
      this.createMap(mapOptions, geolocationOptions)
    }
  }

  createMap = (mapOptions, geolocationOptions) => {
    this.map = new mapboxgl.Map(mapOptions)
    this.map.addControl(
      new mapboxgl.GeolocateControl({
        positionOptions: geolocationOptions,
        trackUserLocation: true
      })
    )
    this.map.on('load', () => {
      this.map.addSource('photos',
      {
        type: 'geojson',
        data: '/map.json'
      })
      this.map.addLayer({ id: 'photos', type: 'circle', source: 'photos'});
    })
  }

  render(){
    const styles = {
      width:            '100%',
      height:           '500px',
      backgroundColor:  'azure'
    }
    return <div style={styles} ref={el => this.mapContainer = el}></div>
  }

  componentWillUnmount() {
    this.map.remove()
  }
}

export default Map
