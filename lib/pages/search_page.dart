import 'package:flutter/material.dart';

import '../services/url_launcher_service.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/search/search_card.dart';
import '../widgets/search/search_category.dart';
import '../widgets/search/service_icon.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  //==================================================
  // プレミアムガラスカード
  //==================================================

  /// メモ画面と同じプレミアムガラスカード用Decoration。
  ///
  /// ・すごく薄いブルー～ごく薄いブルー～薄いブルーのグラデーション
  /// ・薄いブルーの外側Border
  /// ・柔らかい立体シャドウ
  ///
  /// MemoPageと同じデザイン言語を使用する。
  BoxDecoration _buildGlassDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(
            250,
            253,
            255,
            0.98,
          ),
          Color.fromRGBO(
            247,
            251,
            255,
            0.98,
          ),
          Color.fromRGBO(
            239,
            247,
            255,
            0.98,
          ),
        ],
        stops: [
          0.0,
          0.52,
          1.0,
        ],
      ),

      //================================================
      // メモ画面と同じ角丸
      //================================================

      borderRadius:
          AppRadius.card,

      //================================================
      // メモ画面と同系統の薄いブルーBorder
      //================================================

      border: Border.all(
        color: const Color.fromRGBO(
          157,
          201,
          246,
          0.78,
        ),
        width: 1.5,
      ),

      //================================================
      // メモ画面と同系統の柔らかい立体影
      //================================================

      boxShadow: const [
        //================================================
        // 下方向の柔らかい影
        //================================================

        BoxShadow(
          color: Color.fromRGBO(
            92,
            143,
            196,
            0.18,
          ),
          blurRadius: 22,
          spreadRadius: 2,
          offset: Offset(
            0,
            10,
          ),
        ),

        //================================================
        // 近距離の立体影
        //================================================

        BoxShadow(
          color: Color.fromRGBO(
            125,
            170,
            215,
            0.12,
          ),
          blurRadius: 8,
          spreadRadius: 0,
          offset: Offset(
            0,
            3,
          ),
        ),
      ],
    );
  }

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
          child: Container(
            //================================================
            // カード位置
            //================================================
            //
            // MemoPageと同じAppSpacing.xsを設定。
            //
            // AppBarからカード上端までの距離を
            // メモ画面と統一する。
            //================================================

            margin: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
            ),

            //================================================
            // プレミアムガラスカード
            //================================================

            decoration:
                _buildGlassDecoration(),

            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  //==========================================
                  // ホール検索
                  //==========================================

                  SearchCategory(
                    title: 'ホール検索',
                    icon: 'hall_search',
                    children: [
                      SearchCard(
                        title: 'P-WORLD',
                        subtitle:
                            '全国のホール・設置機種を検索',
                        icon: const ServiceIcon(
                          icon: 'p_world',
                          size: 38,
                        ),
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
                        icon: const ServiceIcon(
                          icon: 'dmm_pachitown',
                          size: 38,
                        ),
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
                    icon: 'model_analysis',
                    children: [
                      SearchCard(
                        title: '一撃',
                        subtitle:
                            '設定差・小役確率・天井情報',
                        icon: const ServiceIcon(
                          icon: 'ichigeki',
                          size: 38,
                        ),
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
                        icon: const ServiceIcon(
                          icon: 'pachi7',
                          size: 38,
                        ),
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
                    icon: 'event_search',
                    children: [
                      SearchCard(
                        title: 'X（旧Twitter）',
                        subtitle:
                            'イベント情報・店舗情報を検索',
                        icon: const ServiceIcon(
                          icon: 'x',
                          size: 38,
                        ),
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
                    icon: 'useful_tools',
                    children: [
                      //========================================
                      // Googleマップ
                      //========================================

                      SearchCard(
                        title: 'Googleマップ',
                        subtitle:
                            '現在地からホールを探す',
                        icon: const ServiceIcon(
                          icon: 'google_map',
                          size: 38,
                        ),
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
                        icon: const ServiceIcon(
                          icon: 'google_calendar',
                          size: 38,
                        ),
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
                    icon: 'watch_video',
                    children: [
                      SearchCard(
                        title: 'YouTube',
                        subtitle:
                            '実戦動画・設定判別・解説動画',
                        icon: const ServiceIcon(
                          icon: 'youtube',
                          size: 38,
                        ),
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
      ),
    );
  }
}