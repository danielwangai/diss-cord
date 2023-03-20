import { ethers } from 'ethers'
import {Routes , Route } from "react-router-dom"

// ABIs
import Disscord from './abis/Disscord.json'

// Config
import config from './config.json'
import CreateUsers from "./components/create-users";
import Home from "./Home";

function App() {
    return (
      <div>
          <Routes>
              <Route path="/" element={<Home/> } />
              <Route path="/create-user" element={<CreateUsers/> } />
          </Routes>
      </div>
  );
}

export default App;
