import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  workers: 1,
  reporter: 'html',
  timeout: 60000,
  expect: { timeout: 15000 },

  use: {
    baseURL: 'http://localhost:4200',
    trace: 'on-first-retry',
    screenshot: 'on',
  },

  projects: [
    {
      name: 'Android - Pixel 7',
      use: {
        ...devices['Pixel 7'],
      },
    },
  ],
});