import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';

function App() {
  return (
    <div className="container-fluid bg-dark text-light">
      <div className="row">
        <nav className="col-md-2 d-none d-md-block bg-secondary sidebar">
          <div className="position-sticky">
            <ul className="nav flex-column">
              <li className="nav-item">
                <a className="nav-link active text-light" href="#">Dashboard</a>
              </li>
              <li className="nav-item">
                <a className="nav-link text-light" href="#">Analyse</a>
              </li>
              <li className="nav-item">
                <a className="nav-link text-light" href="#">Quarantaine</a>
              </li>
              <li className="nav-item">
                <a className="nav-link text-light" href="#">Protection en temps réel</a>
              </li>
              <li className="nav-item">
                <a className="nav-link text-light" href="#">Réseau</a>
              </li>
              <li className="nav-item">
                <a className="nav-link text-light" href="#">Paramètres</a>
              </li>
            </ul>
          </div>
        </nav>
        <main className="col-md-9 ms-sm-auto col-lg-10 px-md-4">
          <h1 className="mt-4">Bienvenue dans l'Antivirus Cyberpunk</h1>
          <p>Statut : Actif</p>
        </main>
      </div>
    </div>
  );
}

export default App;