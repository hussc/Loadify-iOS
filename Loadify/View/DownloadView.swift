//
//  DownloadView.swift
//  Loadify
//
//  Created by Vishweshwaran on 5/9/22.
//

import SwiftUI
import LogKit
import LoadifyKit

struct DownloadView: View {
    
    @StateObject var viewModel: DownloaderViewModel = DownloaderViewModel()
    @State private var selectedQuality: VideoQuality = .none
    @Environment(\.presentationMode) var presentationMode
    
    var details: VideoDetails
    
    var body: some View {
        GeometryReader { geomentry in
            ZStack {
                LoadifyColors.appBackground
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                        .frame(height: geomentry.size.height * 0.032)
                    VStack {
                        VStack {
                            thumbnailView
                            videoContentView
                        }
                    }
                    .cardView(color: LoadifyColors.textfieldBackground)
                    Spacer()
                    footerView
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { navigationBar(geomentry) }
            .alert(isPresented: $viewModel.showSettingsAlert, content: { permissionAlert })
            .showAlert(item: $viewModel.downloadError) {
                AlertUI(title: $0.localizedDescription, subtitle: Texts.tryAgain.randomElement())
            }
            .showAlert(isPresented: $viewModel.isDownloaded) {
                AlertUI(title: Texts.downloadedTitle, subtitle: Texts.downloadedSubtitle, alertType: .success)
            }
            .showLoader(Texts.downloading, isPresented: $viewModel.showLoader)
        }
    }
    
    private var thumbnailView: some View {
        ZStack(alignment: .bottomTrailing) {
            ImageView(urlString: details.thumbnails[details.thumbnails.count - 1].url) {
                thumbnailModifier(image: LoadifyAssets.notFound)
            } image: {
                thumbnailModifier(image: $0)
            } onLoading: {
                ProgressView()
            }
            durationView
                .offset(x: -5, y: -5)
        }
    }
    
    private func thumbnailModifier(image: Image) -> some View {
        image
            .resizable()
            .frame(minHeight: 188)
            .scaledToFit()
            .clipped()
    }
    
    private var durationView: some View {
        Text(details.lengthSeconds.getDuration)
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.6).cornerRadius(4))
    }
    
    private var videoContentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            videoTitleView
                .padding(.vertical, 8)
            ChannelView(
                name: details.ownerChannelName,
                profileImage: details.author.thumbnails[details.author.thumbnails.count - 1].url,
                subscriberCount: details.author.subscriberCount
            )
            .padding(.all, 8)
            videoInfoView
                .padding(.all, 8)
            menuView
                .padding(.vertical, 8)
        }
        .padding(.horizontal, 12)
    }
    
    private var menuView: some View {
        Menu {
            Button(VideoQuality.high.description) { didTapOnQuality(.high) }
            Button(VideoQuality.medium.description) { didTapOnQuality(.medium) }
            Button(VideoQuality.low.description) { didTapOnQuality(.low) }
        } label: {
            MenuButton(title: selectedQuality.description)
        }
    }
    
    private var videoTitleView: some View {
        Text(details.title)
            .foregroundColor(.white)
            .font(.title3)
            .bold()
            .lineLimit(2)
    }
    
    private var videoInfoView: some View {
        ZStack(alignment: .center) {
            InfoView(title: details.likes?.toUnits ?? "N/A", subTitle: "Likes")
                .frame(maxWidth: .infinity, alignment: .leading)
            InfoView(title: details.viewCount.format, subTitle: "Views")
                .frame(maxWidth: .infinity, alignment: .center)
            InfoView(title: details.publishDate.formatter(), subTitle: details.publishDate.formatter(.year))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 4)
    }
    
    private var footerView: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await didTapDownload(quality: selectedQuality)
                }
            } label: {
                Text("Download")
                    .bold()
            }
            .buttonStyle(CustomButtonStyle(isDisabled: selectedQuality == .none ? true: false))
            .disabled(selectedQuality == .none ? true: false)
            madeWithSwift
        }
    }
    
    private var madeWithSwift: some View {
        Text("Made with 💙 using Swift")
            .font(.footnote)
            .foregroundColor(LoadifyColors.greyText)
    }
    
    private var permissionAlert: Alert {
        Alert(
            title: Text(Texts.photosAccessTitle),
            message: Text(Texts.photosAccessSubtitle),
            primaryButton: .default(Text("Settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }),
            secondaryButton: .default(Text("Cancel"))
        )
    }
    
    private var backButton: some View {
        Image(systemName: "chevron.backward")
            .font(Font.body.weight(.bold))
            .onTapGesture {
                presentationMode.wrappedValue.dismiss()
            }
    }
    
    private var loadifyLogo: some View {
        LoadifyAssets.loadifyHorizontal
            .resizable()
            .scaledToFit()
    }
    
    @ToolbarContentBuilder
    private func navigationBar(_ geomentry: GeometryProxy) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            backButton.foregroundColor(LoadifyColors.blueAccent)
        }
        ToolbarItem(placement: .principal) {
            loadifyLogo.frame(height: geomentry.size.height * 0.050)
        }
    }
    
    private func didTapOnQuality(_ quality: VideoQuality) {
        selectedQuality = quality
    }
    
    private func didTapDownload(quality: VideoQuality) async {
        await viewModel.downloadVideo(url: details.videoUrl, with: quality)
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                DownloadView(details: .previews)
            }
            .previewDevice("iPhone 13 Pro Max")
            NavigationView {
                DownloadView(details: .previews)
            }
            .navigationBarTitleDisplayMode(.inline)
            .previewDevice("iPhone SE (3rd generation)")
        }
    }
}
