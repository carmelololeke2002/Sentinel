use std::fs;
use std::path::Path;
use std::time::Duration;
use notify::{Watcher, RecommendedWatcher, RecursiveMode, watcher};
use std::sync::mpsc::channel;

const EICAR_SIGNATURE: &str = "X5O!P%@AP[4\"PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*";

fn scan_file(file_path: &Path) -> bool {
    if let Ok(content) = fs::read_to_string(file_path) {
        return content.contains(EICAR_SIGNATURE);
    }
    false
}

// Main entry point for the Rust-based agent
fn main() {
    println!("Antivirus agent starting...");

    // Configuration du watcher pour surveiller les fichiers
    let (tx, rx) = channel();
    let mut watcher: RecommendedWatcher = watcher(tx, Duration::from_secs(2)).unwrap();

    // Chemin à surveiller (par exemple, le répertoire utilisateur)
    let path_to_watch = "C:/Users";
    watcher.watch(path_to_watch, RecursiveMode::Recursive).unwrap();

    println!("Surveillance des fichiers activée sur : {}", path_to_watch);

    // Boucle principale pour écouter les événements
    loop {
        match rx.recv() {
            Ok(event) => {
                println!("Événement détecté : {:?}", event);
                if let notify::EventKind::Create(_) = event.kind {
                    if let Some(path) = event.paths.get(0) {
                        if scan_file(path) {
                            println!("Fichier malveillant détecté et mis en quarantaine : {:?}", path);
                            // TODO: Ajouter le fichier à la quarantaine
                        }
                    }
                }
            }
            Err(e) => println!("Erreur lors de la surveillance : {:?}", e),
        }
    }

    // TODO: Implement file scanning, memory monitoring, and live protection
}