<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('monitoring_models', function (Blueprint $table) {
            if (!Schema::hasColumn('monitoring_models', 'survey_schedule_id')) {
                $table->string('survey_schedule_id')->nullable()->after('pengajuan_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('monitoring_models', function (Blueprint $table) {
            if (Schema::hasColumn('monitoring_models', 'survey_schedule_id')) {
                $table->dropColumn('survey_schedule_id');
            }
        });
    }
};
