import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('http://localhost:4200/');
  await page.goto('http://localhost:4200/#/login');
  await expect(page.getByRole('img', { name: 'ArquiTech' })).toBeVisible();
  await page.getByRole('textbox', { name: 'Correo electrónico' }).click();
  await page.getByRole('textbox', { name: 'Correo electrónico' }).fill('supervisor.mobile@arquitech.com');
  await page.getByRole('textbox', { name: 'Contraseña' }).click();
  await page.getByRole('textbox', { name: 'Contraseña' }).fill('Arquitech123!');
  await page.getByRole('textbox', { name: 'Contraseña' }).press('Enter');
  await expect(page).toHaveURL(/#\/projects$/);
});