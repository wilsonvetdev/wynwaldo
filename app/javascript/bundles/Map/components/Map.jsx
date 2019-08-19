import React, { Component } from 'react'
import SprayCan from './images/paintcan.svg';
import { styles } from './styles'

const MAP_CENTER = [-80.199145, 25.800791]

class Map extends Component {
  state = { 
    currentLoc: [],
    photos: []
  }

  createGeoJson = (photos) => {
    if(!photos || photos.length === 0){
      return (
        {
          type: "FeatureCollection",
          features: {}
        }
      )
    }
    return (
      {
        type: "FeatureCollection",
        features: photos.map(photo => (
          {
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [photo.longitude, photo.latitude]
            },
            properties: {
              id: photo.id,
              image: photo.image
            }
          }
        ))
      }
    )
  }

  fetchPhotos = (photo, userPosition) => {
    let url = ""
    let origin = photo ? photo.coordinates : false
    if(userPosition){
      const lat = photo ? photo.coordinates[1] : userPosition.coords.latitude
      const lng = photo ? photo.coordinates[0] : userPosition.coords.longitude  
      const params = photo ? `photoId=${photo.id}&related=true` : 'related=false'
      url = `/map.json?latitude=${lat}&longitude=${lng}&${params}`
      origin = [userPosition.coords.longitude, userPosition.coords.latitude]
    } else {
      url = '/map.json?related=false'
    }

    const destination = photo ? [photo.coordinates[0], photo.coordinates[1]] : false
    
    fetch(url)
      .then(response => response.json())
      .then(data => {
        console.log(data.photos)
        this.setState({photos: data.photos, criteria: data.criteria})
      })

    return {origin, destination}
  }

  setupNavigation = ({origin, destination}) => {
    this.map.flyTo({
      center: origin || MAP_CENTER
    })
    if(this.props.showNavigation && origin && destination) {
      // set initial origin and destination
      this.directions.setOrigin(origin)
      this.directions.setDestination(destination)

      // register callback to update navigation if user location changes
      this.geolocateControl.on('geolocate', (pos) => {
        console.log(pos.coords)
        this.directions.setOrigin([pos.coords.longitude, pos.coords.latitude])
      })
    }
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
            const startEnd = this.fetchPhotos(this.props.photo, position)
            this.props.photo && this.setupNavigation(startEnd)
          },
          // failure callback
          () => {
            const startEnd = this.fetchPhotos(this.props.photo)
            this.props.photo && this.setupNavigation(startEnd)
          },
          // options
          geolocationOptions
        );
      } // end geolocation 
      if(this.props.photo){
        this.popup = new mapboxgl.Popup()
        .setLngLat(this.props.photo.coordinates)
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
    this.map.flyTo({center: [photo.longitude, photo.latitude], zoom: 18})
    this.popup && this.popup.remove()
    this.popup = new mapboxgl.Popup()
      .setLngLat([photo.longitude, photo.latitude])
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
  
  componentDidUpdate(prevProps, prevState) {
    if (JSON.stringify(this.state.photos) !== JSON.stringify(prevState.photos)) {
      if(this.props.showMarkers && this.state.photos.length > 0){
        this.map.addSource('photos',
        {
          type: 'geojson',
          data: console.log(this.createGeoJson(this.state.photos)) || this.createGeoJson(this.state.photos),
          cluster: true,
          clusterMaxZoom: 24,
          clusterRadius: 50,
        })
        this.map.addLayer({
          id: 'photos',
          type: 'symbol',
          source: 'photos',
          layout: {
            'icon-image': 'paintcan',
            'icon-size': 0.1,
            'icon-allow-overlap': true,
          }
        });
        this.map.addLayer({
          id: 'clusters',
          type: 'circle',
          source: 'photos',
          filter: ['has', 'point_count'],
          paint: { "circle-color": ["rgba", 0,0,0,0] }
        })
        this.map.addLayer({
          id: "cluster-count",
          type: "symbol",
          source: "photos",
          filter: ["has", "point_count"],
          layout: {
            "text-field": "{point_count_abbreviated}",
            "text-font": ["DIN Offc Pro Medium", "Arial Unicode MS Bold"],
            "text-size": 12
          }
        });
        this.map.on('click', 'photos', this.handleMarkerClick)
      } // end markers
    }
  }

  componentWillUnmount() {
    this.map.remove()
  }

  render(){
    const styles = {
      width:            '100%',
      height:           '100%',
      backgroundColor:  'azure',
      margin:           '0'
    }
    const { showList } = this.props
    const { photos, criteria } = this.state
    return(
      <React.Fragment>
        {criteria && photos.length > 0 && <h1 className="title-h1">{criteria}</h1>}
        {
          (showList && photos.length > 0) &&
          <section className="tr-section">
            <ul className="tr-list">
              {photos.map(photo => (
                <li className="tr-list-item" key={photo.id}>
                  <div>
                    <a href={photo.location}>
                      <img src={photo.image} id={`photo-${photo.id}`}/>
                    </a>
                    <div className="bottom-right">
                        {photo.visits} visits
                    </div>
                    <p>
                      {photo.distance.toFixed(2)} mi away {this.props.photo && "from this photo"}
                    </p>
                    <p>
                      Posted by: {photo.user.email}
                    </p>
                  </div>
                  <div>
                    {!this.props.photo && (
                      <button className="show-btn" onClick={() => this.flyTo(photo)}>
                        Show on Map
                      </button>
                    )}
                  </div>
                </li>
              ))}
            </ul>
          </section>
        }
        <div className="map-container">
          <div style={styles} ref={el => this.mapContainer = el}></div>
        </div>
      </React.Fragment>
    )
  }
}

export default Map
