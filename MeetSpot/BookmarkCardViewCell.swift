//
//  BookmarkCardViewCell.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/14.
//

import UIKit
import MapKit

final class BookmarkCardViewCell: UITableViewCell {
  // MARK: - Constants
  private static let viewConstraint: CGFloat = 12
  private static let cornerRadius: CGFloat = 7
  private static let font: UIFont = UIFont.systemFont(ofSize: 22)
  
  // MARK: - Views
  /// contentViewの台紙となるView
  lazy var cardView: UIView = {
    let view: UIView = UIView()
    view.layer.cornerRadius = BookmarkCardViewCell.cornerRadius
    view.backgroundColor = .white
    
    // Border
    view.layer.borderColor = UIColor.gray.cgColor
    view.layer.borderWidth = 0.1
    
    // Shadow
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 2, height: 2)
    view.layer.shadowRadius = 2
    view.layer.shadowOpacity = 0.15
    
    // Constraints
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setNeedsUpdateConstraints()
    
    return view
  }()
  
  /// 目的地を表示するマップ
  lazy var mapView: MKMapView = {
    let mapView:MKMapView = MKMapView()
    mapView.layer.cornerRadius = BookmarkCardViewCell.cornerRadius
    mapView.clipsToBounds = true
    
    // Constraints
    mapView.translatesAutoresizingMaskIntoConstraints = false
    
    return mapView
  }()
  
  /// 目的地を表示するLabel
  lazy var destinationLabel: UILabel = {
    let label: UILabel = UILabel()
    label.font = BookmarkCardViewCell.font
    label.text = "Destination Label"
    label.clipsToBounds = true
    
    // Constraints
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  /// 所要時間を表示するLabel
  lazy var travelTimeLabel: UILabel = {
    let label: UILabel = UILabel()
    label.font = BookmarkCardViewCell.font
    label.text = "Travel Time Label"
    label.clipsToBounds = true
    
    // Constraints
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  /// 距離を表示するLabel
  lazy var routeLengthLabel: UILabel = {
    let label: UILabel = UILabel()
    label.font = BookmarkCardViewCell.font
    label.text = "Route Length Label"
    label.clipsToBounds = true
    
    // Constraints
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  // MARK: - Constructor
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    // 選択時のハイライトを無効化
    selectionStyle = .none
    
    layoutCardView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  // MARK: - Override Methods
  /// 制約の更新
  override func updateConstraints() {
    // Card View
    NSLayoutConstraint.activate([
      cardView.widthAnchor.constraint(equalToConstant: self.bounds.width - BookmarkCardViewCell.viewConstraint * 2),
      cardView.heightAnchor.constraint(equalToConstant: self.bounds.height - BookmarkCardViewCell.viewConstraint * 2),
      cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
      cardView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
    
    // Map View
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: BookmarkCardViewCell.viewConstraint),
      mapView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -BookmarkCardViewCell.viewConstraint),
      mapView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: BookmarkCardViewCell.viewConstraint),
      mapView.trailingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: BookmarkCardViewCell.viewConstraint + 120)
    ])
    
    // Destination Label
    NSLayoutConstraint.activate([
      destinationLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: BookmarkCardViewCell.viewConstraint),
      destinationLabel.leadingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: BookmarkCardViewCell.viewConstraint),
      destinationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -BookmarkCardViewCell.viewConstraint)
    ])
    
    // Route Length Label
    NSLayoutConstraint.activate([
      routeLengthLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -BookmarkCardViewCell.viewConstraint),
      routeLengthLabel.leadingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: BookmarkCardViewCell.viewConstraint),
      routeLengthLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -BookmarkCardViewCell.viewConstraint)
    ])
    
    // Travel Time Label
    NSLayoutConstraint.activate([
      travelTimeLabel.bottomAnchor.constraint(equalTo: routeLengthLabel.topAnchor, constant: -BookmarkCardViewCell.viewConstraint),
      travelTimeLabel.leadingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: BookmarkCardViewCell.viewConstraint),
      travelTimeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -BookmarkCardViewCell.viewConstraint)
    ])
    
    super.updateConstraints()
  }
  
  /// `UIView#frame`の更新
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  /// 選択時に呼び出される処理
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}

extension BookmarkCardViewCell {
  private func layoutCardView() {
    // Card View
    addSubview(cardView)
    
    // Map View
    cardView.addSubview(mapView)
    
    // Destination Label
    cardView.addSubview(destinationLabel)
    
    // Travel Time Label
    cardView.addSubview(travelTimeLabel)
    
    // Route Length Label
    cardView.addSubview(routeLengthLabel)
    
    contentView.backgroundColor = .clear
  }
}
