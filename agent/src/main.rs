use clap::Parser;

/// Antivirus agent - minimal example
#[derive(Parser)]
#[command(version, about = "Antivirus agent minimal CLI")]
struct Args {
    /// Verbose output
    #[arg(short, long)]
    verbose: bool,
}

fn main() {
    let args = Args::parse();
    if args.verbose {
        println!("Antivirus agent démarré en mode verbeux");
    } else {
        println!("Antivirus agent démarré");
    }
}
fn main() {
    println!("Agent Antivirus démarré");
}