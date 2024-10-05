<?php

declare(strict_types=1);

namespace App\Providers;

use DateTimeImmutable;

final class Foo
{
    public static function getDateTime(?string $format): string
    {
        return (new DateTimeImmutable())->format($format ?? 'Y-m-d H:i:s');
    }

    public function ping(): string
    {
        return 'pong';
    }
}
