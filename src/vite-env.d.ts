
/// <reference types="vite/client" />

// Définition des types pour l'API SpeechRecognition
interface Window {
  SpeechRecognition?: typeof SpeechRecognition;
  webkitSpeechRecognition?: typeof SpeechRecognition;
}
