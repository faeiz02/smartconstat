import { Injectable, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private currentTheme: 'light' | 'dark' = 'light';

  constructor(@Inject(PLATFORM_ID) private platformId: Object) {
    if (isPlatformBrowser(this.platformId)) {
      const savedTheme = localStorage.getItem('theme');
      if (savedTheme === 'light' || savedTheme === 'dark') {
        this.currentTheme = savedTheme;
      } else {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        this.currentTheme = prefersDark ? 'dark' : 'light';
      }
      this.applyTheme();
    }
  }

  toggleTheme(): void {
    const next = this.currentTheme === 'dark' ? 'light' : 'dark';
    this.currentTheme = next;
    if (isPlatformBrowser(this.platformId)) {
      localStorage.setItem('theme', next);
    }
    this.applyTheme();
  }

  getCurrentTheme(): 'light' | 'dark' {
    return this.currentTheme;
  }

  isDark(): boolean {
    return this.currentTheme === 'dark';
  }

  private applyTheme(): void {
    if (isPlatformBrowser(this.platformId)) {
      const theme = this.currentTheme;
      if (theme === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
        document.body.classList.add('dark-mode');
        document.body.classList.remove('light-mode');
      } else {
        document.documentElement.removeAttribute('data-theme');
        document.body.classList.add('light-mode');
        document.body.classList.remove('dark-mode');
      }
    }
  }
}
