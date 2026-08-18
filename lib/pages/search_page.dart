import 'package:flutter/material.dart';

import '../services/url_launcher_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_card.dart';
import '../widgets/search/search_card.dart';
import '../widgets/search/search_category.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: AppCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                //==========================================
                // ホール検索
                //==========================================

                SearchCategory(
                  title: 'ホール検索',
                  icon: Icons.store,
                  children: [
                    SearchCard(
                      title: 'P-WORLD',
                      subtitle:
                          '全国のホール・設置機種を検索',
                      icon: Icons.storefront,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          'P-WORLD',
                          'https://www.p-world.co.jp/',
                        );
                      },
                    ),

                    SearchCard(
                      title: 'DMMぱちタウン',
                      subtitle:
                          'ホール情報・機種情報を検索',
                      icon: Icons.location_city,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          'DMMぱちタウン',
                          'https://p-town.dmm.com/',
                        );
                      },
                    ),
                  ],
                ),

                //==========================================
                // 機種解析
                //==========================================

                SearchCategory(
                  title: '機種解析',
                  icon: Icons.auto_graph,
                  children: [
                    SearchCard(
                      title: '一撃',
                      subtitle:
                          '設定差・小役確率・天井情報',
                      icon: Icons.analytics,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          '一撃',
                          'https://1geki.jp/',
                        );
                      },
                    ),

                    SearchCard(
                      title: 'パチ７',
                      subtitle:
                          '初心者向けの機種解説',
                      icon: Icons.menu_book,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          'パチ７',
                          'https://pachiseven.jp/',
                        );
                      },
                    ),
                  ],
                ),

                //==========================================
                // イベント検索
                //==========================================

                SearchCategory(
                  title: 'イベント検索',
                  icon: Icons.local_fire_department,
                  children: [
                    SearchCard(
                      title: 'X（旧Twitter）',
                      subtitle:
                          'イベント情報・店舗情報を検索',
                      icon: Icons.campaign,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          'X（旧Twitter）',
                          'https://x.com/',
                        );
                      },
                    ),
                  ],
                ),

                //==========================================
                // 便利ツール
                //==========================================

                SearchCategory(
                  title: '便利ツール',
                  icon: Icons.map,
                  children: [
                    //========================================
                    // Googleマップ
                    //========================================

                    SearchCard(
                      title: 'Googleマップ',
                      subtitle:
                          '現在地からホールを探す',
                      icon: Icons.map_outlined,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          'Googleマップ',
                          'https://maps.google.com/',
                        );
                      },
                    ),

                    //========================================
                    // Googleカレンダー
                    //========================================

                    SearchCard(
                      title: 'Googleカレンダー',
                      subtitle:
                          'イベント予定を確認する',
                      icon:
                          Icons.calendar_month_outlined,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          'Googleカレンダー',
                          'https://calendar.google.com/',
                        );
                      },
                    ),
                  ],
                ),

                //==========================================
                // 動画視聴
                //==========================================

                SearchCategory(
                  title: '動画視聴',
                  icon: Icons.play_circle_fill,
                  children: [
                    SearchCard(
                      title: 'YouTube',
                      subtitle:
                          '実戦動画・設定判別・解説動画',
                      icon: Icons.ondemand_video,
                      onTap: () {
                        UrlLauncherService.open(
                          context,
                          'YouTube',
                          'https://www.youtube.com/',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}