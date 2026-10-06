import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('http://localhost:4200/#/login');
  await page.getByRole('textbox', { name: 'Correo electrónico' }).click();
  await page.getByRole('textbox', { name: 'Correo electrónico' }).fill('supervisor.mobile@arquitech.com');
  await page.getByRole('textbox', { name: 'Contraseña' }).click();
  await page.getByRole('textbox', { name: 'Contraseña' }).fill('Arquitech123!');
  await page.getByRole('textbox', { name: 'Contraseña' }).press('Enter');
  await page.getByRole('button', { name: 'Nuevo proyecto', exact: true }).click();
  await page.getByRole('textbox', { name: 'Nombre', exact: true }).click();
  await page.getByRole('textbox', { name: 'Nombre', exact: true }).fill('E2E Proyecto Playwright');
  await page.getByRole('textbox', { name: 'Ubicación', exact: true }).click();
  await page.getByRole('textbox', { name: 'Ubicación', exact: true }).fill('Lima - obra E2E Playwright');
  await page.getByRole('button', { name: /Contratista/ }).click();
  await page.getByRole('menuitem', { name: 'Contratista Prueba', exact: true }).click();
  await page.getByRole('button', { name: /^Fecha de fin/ }).click();
  await page.getByRole('button', { name: 'Cambiar a cuadro de texto', exact: true }).click();
  await page.getByRole('textbox', { name: 'Introduce una fecha', exact: true }).click();
  await page.getByRole('textbox', { name: 'Introduce una fecha', exact: true }).fill('31/12/2030');
  await page.getByRole('button', { name: /^aceptar$/i }).click();
  await page.getByRole('textbox', { name: 'Presupuesto', exact: true }).click();
  await page.getByRole('textbox', { name: 'Presupuesto', exact: true }).fill('50000');
  await page.getByRole('textbox', { name: 'Progreso', exact: true }).click();
  await page.getByRole('textbox', { name: 'Progreso', exact: true }).fill('0');
  await page.getByRole('button', { name: 'Crear', exact: true }).click();
  await expect(page).toHaveURL(/#\/projects$/);
  await expect(page.getByText('E2E Proyecto Playwright', { exact: true })).toBeVisible();
});
