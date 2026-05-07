import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

@Component({
  selector: 'app-coming-soon',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="coming-soon-container">
      <div class="glass-card">
        <span class="material-icons build-icon">build_circle</span>
        <h1>Module en cours de développement</h1>
        <p>Cette section est actuellement en cours de construction pour vous offrir les meilleures fonctionnalités de gestion.</p>
        
        <div class="features-preview">
          <h3>Bientôt disponible :</h3>
          <ul>
            <li><span class="material-icons">check_circle</span> Gestion avancée des données</li>
            <li><span class="material-icons">check_circle</span> Tableaux de bord analytiques</li>
            <li><span class="material-icons">check_circle</span> Export PDF & Excel</li>
          </ul>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .coming-soon-container {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      padding: 40px;
    }
    .glass-card {
      background: var(--bg-card);
      backdrop-filter: var(--glass-blur);
      -webkit-backdrop-filter: var(--glass-blur);
      border: 1px solid var(--border-color);
      border-radius: 24px;
      padding: 60px 40px;
      max-width: 600px;
      text-align: center;
      box-shadow: var(--shadow-card);
    }
    .build-icon {
      font-size: 80px;
      color: #6c63ff;
      margin-bottom: 20px;
      opacity: 0.9;
    }
    h1 {
      font-size: 28px;
      color: var(--text-main);
      margin-bottom: 16px;
    }
    p {
      color: var(--text-secondary);
      font-size: 16px;
      line-height: 1.6;
      margin-bottom: 40px;
    }
    .features-preview {
      background: rgba(108, 99, 255, 0.05);
      border-radius: 16px;
      padding: 24px;
      text-align: left;
    }
    h3 {
      font-size: 14px;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: #6c63ff;
      margin-bottom: 16px;
    }
    ul {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    li {
      display: flex;
      align-items: center;
      gap: 12px;
      color: var(--text-main);
      font-size: 15px;
      margin-bottom: 12px;
    }
    li .material-icons {
      color: #2ed573;
      font-size: 20px;
    }
  `]
})
export class ComingSoonComponent {
  constructor(private router: Router) {}
}
