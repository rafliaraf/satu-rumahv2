<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @param  string  ...$roles
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.'
            ], 401);
        }

        $userRole = strtolower($user->role ?? '');

        // Map role aliases for compatibility
        $normalizedRole = match ($userRole) {
            'admin_dpkp', 'admin' => 'admin',
            'tim_monitoring', 'perwaskim' => 'perwaskim',
            'pengembang' => 'pengembang',
            default => $userRole,
        };

        $allowedRoles = array_map(function ($r) {
            $lower = strtolower($r);
            return match ($lower) {
                'admin_dpkp' => 'admin',
                'tim_monitoring' => 'perwaskim',
                default => $lower,
            };
        }, $roles);

        if (!in_array($normalizedRole, $allowedRoles)) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak: Anda tidak memiliki wewenang role untuk menjalankan fungsi ini.'
            ], 403);
        }

        return $next($request);
    }
}
