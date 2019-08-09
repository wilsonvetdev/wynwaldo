import React from 'react'

class Map extends React.Component {
  componentDidMount() {
    mapboxgl.accessToken = this.props.token
    this.createMap()
  }

  createMap = () => {
    this.map = new mapboxgl.Map({
      container: this.mapContainer,
      style: `mapbox://styles/mapbox/streets-v9`
    })
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
}

export default Map
