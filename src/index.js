import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

import "semantic-ui-css/semantic.min.css";
import reportWebVitals from './reportWebVitals';
import {configureStore} from "@reduxjs/toolkit";
import {Provider} from "react-redux";
import {usersSlice} from "./reducers/users";
import {BrowserRouter} from "react-router-dom";

// store
const store = configureStore({
    reducer: {
        items: usersSlice,
    }, devTools: true
});

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <Provider store={store}>
        <React.StrictMode>
            <BrowserRouter>
                <App />
            </BrowserRouter>
        </React.StrictMode>
    </Provider>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
