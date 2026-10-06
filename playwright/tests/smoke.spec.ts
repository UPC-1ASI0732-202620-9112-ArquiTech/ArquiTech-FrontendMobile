import { test, expect } from '@playwright/test';

test('ArquiTech abre correctamente', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveURL(/localhost:4200\/#\/login/);
});