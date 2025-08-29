import React from "react";
import { BrowserRouter, Routes, Route, NavLink, Outlet } from "react-router-dom";
import "./mainpage.css";

import Welcome from "./Welcome";
import Validator from "./validator";
import TestStepsDetector from "./TestStepsDetector";
import Help from "./Help";
import Contact from "./Contact";

import videoBackground from "./video.mp4";

function Layout() {
  return (
    <>
      {/* Background Video */}
      <video className="bg-video" autoPlay loop muted playsInline>
        <source src={videoBackground} type="video/mp4" />
        Your browser does not support the video tag.
      </video>

      {/* Neon Grid + Glow */}
      <div className="background" />
      <div className="glow-overlay" />

      {/* Navigation */}
      <nav className="navbar">
        <NavLink to="/" className={({isActive}) => "nav-button" + (isActive ? " active" : "")}>Welcome</NavLink>
        <NavLink to="/validator" className={({isActive}) => "nav-button" + (isActive ? " active" : "")}>Validator</NavLink>
        <NavLink to="/detect" className={({isActive}) => "nav-button" + (isActive ? " active" : "")}>Detect Steps</NavLink>
        <NavLink to="/help" className={({isActive}) => "nav-button" + (isActive ? " active" : "")}>Help</NavLink>
        <NavLink to="/contact" className={({isActive}) => "nav-button" + (isActive ? " active" : "")}>Contact</NavLink>
      </nav>

      {/* Routed page */}
      <main style={{ minHeight: "100vh", paddingTop: 90 }}>
        <Outlet />
      </main>
    </>
  );
}

function NotFound() {
  return (
    <section style={{ minHeight: "70vh", display: "grid", placeItems: "center", textAlign: "center" }}>
      <div>
        <h2>😕 Page not found</h2>
        <p>Use the navigation above.</p>
      </div>
    </section>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Welcome />} />
          <Route path="/validator" element={<Validator />} />
          <Route path="/detect" element={<TestStepsDetector />} />
          <Route path="/help" element={<Help />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
