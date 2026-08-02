//
//  TermsView.swift
//  Souqira
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        sectionHeader("1. Acceptance of Terms")
                        bodyText("By accessing or using Souqira, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app.")

                        sectionHeader("2. Use of the Platform")
                        bodyText("Souqira is a marketplace platform for buying, selling, and discovering businesses. You agree to use the platform lawfully and not to post content that is false, misleading, illegal, or harmful.")

                        sectionHeader("3. User Content")
                        bodyText("You are solely responsible for any listings, messages, or content you post. Souqira reserves the right to remove content that violates these terms or applicable law.")

                        sectionHeader("4. Prohibited Content")
                        bodyText("You may not post listings that involve illegal goods or services, adult content, spam, or content that infringes on third-party rights.")

                        sectionHeader("5. Reporting & Moderation")
                        bodyText("Users may report listings that violate these terms. Souqira reviews reports and may remove content or suspend accounts without prior notice.")

                        sectionHeader("6. Blocking Users")
                        bodyText("You may block other users at any time. Blocked users will not be able to contact you through the platform.")
                    }

                    Group {
                        sectionHeader("7. Account Responsibility")
                        bodyText("You are responsible for maintaining the confidentiality of your account credentials. Notify us immediately of any unauthorized use of your account.")

                        sectionHeader("8. Privacy")
                        bodyText("Your use of Souqira is also governed by our Privacy Policy. We collect and process data only as described therein.")

                        sectionHeader("9. Intellectual Property")
                        bodyText("All content, trademarks, and data on Souqira are the property of Souqira or its licensors. You may not copy, reproduce, or distribute any content without permission.")

                        sectionHeader("10. Limitation of Liability")
                        bodyText("Souqira is provided \"as is\". We are not liable for any losses or damages arising from your use of the platform, including but not limited to transactions between users.")

                        sectionHeader("11. Changes to Terms")
                        bodyText("We may update these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.")

                        sectionHeader("12. Contact")
                        bodyText("For questions about these Terms, contact us at support@souqira.com.")
                    }
                }
                .padding(20)
            }
            .navigationTitle("Terms & Conditions")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.primary)
    }

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.secondary)
            .lineSpacing(4)
    }
}
