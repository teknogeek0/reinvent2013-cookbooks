<?php if (!class_exists('CFRuntime')) die('No direct access allowed.');

CFCredentials::set(array(
	'development' => array(
		'key' => '<%= @key %>',
		'secret' => '<%= @secret %>',
		'default_cache_config' => '',
		'certificate_authority' => false
	),
	'@default' => 'development'
));
