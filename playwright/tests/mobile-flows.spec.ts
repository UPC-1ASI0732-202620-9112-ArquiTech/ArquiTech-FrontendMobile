import { test, expect } from '@playwright/test';

const id = Date.now().toString().slice(-6);

test('supervisor cannot sign in with a wrong password', async ({ page }) => {
  await page.goto('/#/login');
  await expect(page.getByRole('img', { name: 'ArquiTech' })).toBeVisible();
  await page.getByRole('textbox', { name: 'Correo electrónico' }).fill('supervisor.mobile@arquitech.com');
  await page.getByRole('textbox', { name: 'Contraseña' }).fill('ClaveIncorrecta123!');
  await page.getByRole('textbox', { name: 'Contraseña' }).press('Enter');
  await expect(page.getByText('El correo o la contraseña son incorrectos.')).toBeVisible();
  await expect(page).toHaveURL(/#\/login$/);
  await page.getByRole('textbox', { name: 'Contraseña' }).fill('Arquitech123!');
  await page.getByRole('textbox', { name: 'Contraseña' }).press('Enter');
  await expect(page).toHaveURL(/#\/projects$/);
  await expect(page.getByRole('button', { name: 'Nuevo proyecto', exact: true })).toBeVisible();
});

test('supervisor cannot create a project without an end date', async ({ page }) => {
  await page.goto('/#/login');
  await page.getByRole('textbox', { name: 'Correo electrónico' }).fill('supervisor.mobile@arquitech.com');
  await page.getByRole('textbox', { name: 'Contraseña' }).fill('Arquitech123!');
  await page.getByRole('textbox', { name: 'Contraseña' }).press('Enter');
  await page.getByRole('button', { name: 'Nuevo proyecto', exact: true }).click();
  await page.getByRole('textbox', { name: 'Nombre', exact: true }).fill(`E2E Proyecto ${id}`);
  await page.getByRole('textbox', { name: 'Ubicación', exact: true }).fill('Lima - obra E2E Playwright');
  await page.getByRole('button', { name: /Contratista/ }).click();
  await page.getByRole('menuitem', { name: 'Contratista Prueba', exact: true }).click();
  await page.getByRole('textbox', { name: 'Presupuesto', exact: true }).fill('50000');
  await page.getByRole('textbox', { name: 'Progreso', exact: true }).fill('0');
  await page.getByRole('button', { name: 'Crear', exact: true }).click();
  await expect(page.getByText('Fecha de fin: Este campo es obligatorio.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Crear', exact: true })).toBeVisible();
  await page.getByRole('button', { name: /^Fecha de fin/ }).click();
  await page.getByRole('button', { name: 'Cambiar a cuadro de texto', exact: true }).click();
  await page.getByRole('textbox', { name: 'Introduce una fecha', exact: true }).fill('31/12/2030');
  await page.getByRole('button', { name: /^aceptar$/i }).click();
  await page.getByRole('button', { name: 'Crear', exact: true }).click();
  await expect(page).toHaveURL(/#\/projects$/);
  await expect(page.getByRole('button', { name: 'Nuevo proyecto', exact: true })).toBeVisible();
});