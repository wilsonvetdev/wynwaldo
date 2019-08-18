import React, { Component } from 'react'
import SprayCan from './images/paintcan.svg';
import { styles } from './styles'

const MAP_CENTER = [-80.199145, 25.800791]

class Map extends Component {
  state = { 
    currentLoc: [],
    photos: []
  }

  createGeoJson = () => {
    // {
    //   type: "FeatureCollection",
    //   features: @photos.map do |photo|
    //     {
    //       type: "Feature",
    //       geometry: {
    //         type: "Point",
    //         coordinates: [photo.longitude, photo.latitude]
    //       },
    //       properties: {
    //         id: photo.id,
    //         image: url_for(photo.image)
    //       }
    //     }
    //   end
    // }
  }

  createMap = (mapOptions, geolocationOptions) => {
    this.map = new mapboxgl.Map(mapOptions)
    this.geolocateControl = new mapboxgl.GeolocateControl({ positionOptions: geolocationOptions, trackUserLocation: true })
    this.map.addControl(this.geolocateControl)
    if(this.props.showNavigation) {
      this.directions = new MapboxDirections({
        accessToken: mapboxgl.accessToken,
        profile: 'mapbox/walking',
        interactive: false,
        controls: {
          inputs: false,
          profileSwitcher: false
        },
        flyTo: false,
        styles
      })
      this.map.addControl(this.directions, 'top-left')
    }

    this.map.on('load', () => {
      this.map.loadImage(SprayCan, (err, img) => !err && this.map.addImage('paintcan', img))
      if ("geolocation" in navigator) {
        navigator.geolocation.getCurrentPosition(
          // success callback
          position => {
            // make request for photos near position.coords
            console.log("got your location")
            fetch(`/map.json?latitude=${position.coords.latitude}&longitude=${position.coords.longitude}`)
              .then(response => response.json())
              .then(data => console.log(data))
            // this.map.flyTo({
            //   center: [position.coords.longitude, position.coords.latitude]
            // })
            // if(this.props.showNavigation) {
            //   // set initial origin and destination
            //   this.directions.setOrigin([position.coords.longitude, position.coords.latitude])
            //   this.directions.setDestination(this.props.coordinates)

            //   // register callback to update navigation if user location changes
            //   this.geolocateControl.on('geolocate', (pos) => {
            //     console.log(pos.coords)
            //     this.directions.setOrigin([pos.coords.longitude, pos.coords.latitude])
            //   })
            // }
          },
          // failure callback
          () => {
            console.log("Couldn't get user location")
            // make request with no location
            fetch(`/map.json`)
              .then(response => response.json())
              .then(data => console.log(data))
          },
          // options
          geolocationOptions
        );
      } // end geolocation 
      // if(this.props.showMarkers){
      //   this.map.addSource('photos',
      //   {
      //     type: 'geojson',
      //     data: '/map.json',
      //     cluster: true,
      //     clusterMaxZoom: 24,
      //     clusterRadius: 50,
      //   })
      //   this.map.addLayer({
      //     id: 'photos',
      //     type: 'symbol',
      //     source: 'photos',
      //     layout: {
      //       'icon-image': 'paintcan',
      //       'icon-size': 0.1,
      //       'icon-allow-overlap': true,
      //     }
      //   });
      //   this.map.addLayer({
      //     id: 'clusters',
      //     type: 'circle',
      //     source: 'photos',
      //     filter: ['has', 'point_count'],
      //     paint: { "circle-color": ["rgba", 0,0,0,0] }
      //   })
      //   this.map.addLayer({
      //     id: "cluster-count",
      //     type: "symbol",
      //     source: "photos",
      //     filter: ["has", "point_count"],
      //     layout: {
      //       "text-field": "{point_count_abbreviated}",
      //       "text-font": ["DIN Offc Pro Medium", "Arial Unicode MS Bold"],
      //       "text-size": 12
      //     }
      //   });
      //   this.map.on('click', 'photos', this.handleMarkerClick)
      // } // end markers
      if(this.props.photo){
        this.popup = new mapboxgl.Popup()
        .setLngLat(this.props.coordinates)
        .setHTML(`
          <div class="popup">
            <a href="/photos/${this.props.photo.id}">
              <img src=${this.props.photo.image} />
            </a>
          </div>
        `)
        .addTo(this.map)
      }
    }) // end onload
  } // end createMap

  handleMarkerClick = e => {
    const map = this.map;
    const { properties, geometry = {} } = e.features[0]
    if (properties.cluster){
      const zoom = map.getZoom() + 1
      const center = [e.lngLat.lng, e.lngLat.lat]
      map.flyTo({ center, zoom })
    }else{
      const coordinates = [...geometry.coordinates]
      this.popup && this.popup.remove()
      this.popup = new mapboxgl.Popup()
        .setLngLat(coordinates)
        .setHTML(`
          <div class="popup">
            <a href="/photos/${properties.id}">
              <img src=${properties.image} />
            </a>
          </div>
        `)
        .addTo(map)
    }
  }

  flyTo = photo => {
    this.map.flyTo({center: photo.coordinates, zoom: 18})
    this.popup && this.popup.remove()
    this.popup = new mapboxgl.Popup()
      .setLngLat(photo.coordinates)
      .setHTML(`
        <div class="popup">
          <a href="${photo.location}">
            <img src=${photo.image} />
          </a>
        </div>
      `).addTo(this.map)
  }

  componentDidMount() {
    const { token } = this.props;
    this.setState({ currentLoc: MAP_CENTER })
    mapboxgl.accessToken = token
    const mapOptions = {
      container: this.mapContainer,
      style: `mapbox://styles/cuellarn/cjz7h4yaq24bv1cmxah88k89k`,
      zoom: 16,
      center: MAP_CENTER
    }
    const geolocationOptions = {
      enableHighAccuracy: true,
      maximumAge        : 30000,
      timeout           : 27000
    }
    this.createMap(mapOptions, geolocationOptions)
  }

  componentWillUnmount() {
    this.map.remove()
  }

  render(){
    const styles = {
      width:            '100%',
      height:           '100vh',
      backgroundColor:  'azure',
      margin:           '0'
    }
    const { showList } = this.props
    const { photos } = this.state
    return(
      <React.Fragment>
        <section className="tr-section">
          <ul className="tr-list">
            {/* {
              showList &&
              photos.map(photo => (
                <li className="tr-list-item" key={photo.id}>
                  <div>
                    <a href={photo.location}>
                      <img src={photo.image}/>
                    </a>
                    <p>
                      {photo.visits} visits
                    </p>
                    <p>
                      Posted by: {photo.user.email}
                    </p>
                  </div>
                  <div>
                    <button className="show-btn" onClick={() => this.flyTo(photo)}>
                      Show on Map
                    </button>
                    <a href={photo.location}>Details</a>
                  </div>
                </li>
              ))
            } */}
          </ul>
        </section>
        <div className="map-container">
          <div style={styles} ref={el => this.mapContainer = el}></div>
        </div>
      </React.Fragment>
    )
  }
}

export default Map
