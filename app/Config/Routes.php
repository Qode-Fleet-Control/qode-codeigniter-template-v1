<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */
$routes->get('/', 'Home::index');

// The fleet's health check (fleet.conf HEALTH_PATH).
$routes->get('health', static fn () => service('response')->setJSON(['status' => 'ok']));
