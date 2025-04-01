//
//  ViewController.swift
//  Metaleon
//
//  Created by trilliwon on 07/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import AVFoundation
import Metaleon
import UIKit

final class CameraViewController: UIViewController {

    var currentFilterMode: FilterMode = .imageFilters

    enum FilterMode: Int {
        case imageFilters
        case visualEffects
    }

    // MARK: - Properties
    private lazy var previewView: MetalTextureDisplayView = {
        let view = MetalTextureDisplayView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var filterNameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor(white: 0, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var filterSilder: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.value = 0.5
        slider.addTarget(self, action: #selector(filterSliderChanged(_:)), for: .valueChanged)
        return slider
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Image Filters", "Visual Effects"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(contentsModeChanged(_:)), for: .valueChanged)
        return control
    }()

    lazy var filterProvider: FilterProvider = {
        let provider = imageFiltersProvider  // Default provider is ImageFiltersProvider
        return provider
    }()

    lazy var imageFiltersProvider = ImageFiltersProvider()
    lazy var visualEffectsProvider = VisualEffectsProvider()

    lazy var videoImageTextureProvider: VideoImageTextureProvider? = {
        let provider = VideoImageTextureProvider(device: MetalDevice.shared.device, delegate: self)
        return provider
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        
        // Initialize the filter name label
        updateFilterNameLabel()
        
        // Start camera
        videoImageTextureProvider?.startRunning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageFiltersProvider.geometryFilter = GeometryFilter(containerBound: self.previewView.bounds)
        updateFilterNameLabel()
    }
    
    private func updateFilterNameLabel() {
        filterNameLabel.text = filterProvider.currentFilterName
        // Ensure the label is visible
        filterNameLabel.isHidden = false
    }

    private func setupUI() {
        // Add subviews
        view.addSubview(previewView)
        view.addSubview(filterSilder)
        view.addSubview(segmentedControl)
        view.addSubview(filterNameLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Filter name label - at the top of the screen
            filterNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filterNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterNameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // Preview view - below the filter name label
            previewView.topAnchor.constraint(equalTo: filterNameLabel.bottomAnchor, constant: 16),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            
            // Filter slider - below the preview
            filterSilder.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 16),
            filterSilder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterSilder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Segmented control - at the bottom
            segmentedControl.topAnchor.constraint(equalTo: filterSilder.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    private func setupGestures() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestures(_:)))
        leftSwipe.direction = .left

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestures(_:)))
        rightSwipe.direction = .right

        previewView.addGestureRecognizer(leftSwipe)
        previewView.addGestureRecognizer(rightSwipe)
        previewView.isUserInteractionEnabled = true
    }

    // MARK: - User Interaction Methods
    @objc func handleSwipeGestures(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            filterProvider.next()
        case .right:
            filterProvider.prev()
        default:
            return
        }
        updateFilterNameLabel()
        filterSilder.value = 0.5
    }

    @objc func filterSliderChanged(_ sender: UISlider) {
        let minValue: Float = 0.5
        let maxValue: Float = 1.0
        let alpha = minValue + (maxValue - minValue) * sender.value
        imageFiltersProvider.updateParameters(with: alpha)
    }

    @objc func contentsModeChanged(_ sender: UISegmentedControl) {
        guard let mode = FilterMode(rawValue: sender.selectedSegmentIndex) else { return }
        switch mode {
        case .imageFilters:  // ImageFilters
            filterProvider = imageFiltersProvider
            filterSilder.isHidden = false
        case .visualEffects:  // VisualEffects
            filterProvider = visualEffectsProvider
            filterSilder.isHidden = true
        }
        currentFilterMode = mode
        updateFilterNameLabel()
    }
}

// MARK: Camera Texture
extension CameraViewController: VideoImageTextureProviderDelegate {

    func videoImageTextureProvider(_: VideoImageTextureProvider, currentTime: CMTime, didProvideTexture texture: MTLTexture) {

        guard let commandBuffer = MetalDevice.shared.makeCommandBuffer() else { return }
        var filteredTexture: MTLTexture
        switch currentFilterMode {
        case .imageFilters:
            filteredTexture = imageFiltersProvider.currentFilterChain?.encode(to: commandBuffer, sourceTexture: texture) ?? texture
        case .visualEffects:
            filteredTexture = visualEffectsProvider.currentVisualEffect?.encode(to: commandBuffer, inputTextures: [0: texture]) ?? texture
        }
        filteredTexture = imageFiltersProvider.geometryFilter?.encode(to: commandBuffer, sourceTexture: filteredTexture) ?? texture

        commandBuffer.commit()
        previewView.display(texture: filteredTexture)
    }
}

// MARK: - Filter Provider
protocol FilterProvider {
    var currentFilterName: String { get }
    func prev()
    func next()
}

class ImageFiltersProvider: FilterProvider {

    var currentFilterName: String {
        return currentFilterChain?.info.name ?? ""
    }

    var geometryFilter: GeometryFilter?
    lazy var chainList = FilterStorage.shared.filterChainList
    var currentFilterChain: FilterChain?
    private var currentIndex: Int = 0

    init() {
        currentFilterChain = chainList[currentIndex]
    }

    // MARK: - Filter Change
    func next() {
        currentFilterChain = nextFilter()
    }

    func prev() {
        currentFilterChain = prevFilter()
    }

    private func nextFilter() -> FilterChain {
        currentIndex += 1
        if currentIndex < chainList.count {
            return chainList[currentIndex]
        } else {
            currentIndex = 0
            return chainList[currentIndex]
        }
    }

    private func prevFilter() -> FilterChain {
        currentIndex -= 1
        if currentIndex >= 0 {
            return chainList[currentIndex]
        } else {
            currentIndex = chainList.count - 1
            return chainList[currentIndex]
        }
    }

    // MARK: - Upate parameters
    func updateParameters(with value: Float) {
        currentFilterChain?.updateIntensity(with: value)
    }
}

class VisualEffectsProvider: FilterProvider {

    var currentFilterName: String {
        return (currentVisualEffect as? BasicRenderFilter)?.description ?? ""
    }

    var currentVisualEffect: Filter?
    private var currentIndex: Int = 0

    init() {
        currentVisualEffect = allEffects[currentIndex]
    }

    // MARK: - Filter Change
    func next() {
        currentVisualEffect = nextFilter()
    }

    func prev() {
        currentVisualEffect = prevFilter()
    }

    private func nextFilter() -> Filter {
        currentIndex += 1
        if currentIndex < allEffects.count {
            return allEffects[currentIndex]
        } else {
            currentIndex = 0
            return allEffects[currentIndex]
        }
    }

    private func prevFilter() -> Filter {
        currentIndex -= 1
        if currentIndex >= 0 {
            return allEffects[currentIndex]
        } else {
            currentIndex = allEffects.count - 1
            return allEffects[currentIndex]
        }
    }

    var allEffects: [Filter] {
        return [
            oldFilm,
            vhsCamera,
            chromaticVHS,
            vcr,
            vhsTracking,
            rbgShiftEdge,
            vhsTape,
            vhs,
            glitch,
            trail,
            grid49,
            colorIllusion,
            rgbSpark,
            trippy,
            shake,
            soul,
            spring,
            hstep,
            vstep,
            gridColor,
            tile,
            mirror2right,
            mirror4righttop,
        ]
    }

    var oldFilm: OldFilmEffectFilter = OldFilmEffectFilter()
    var vhsCamera = VHSCameraEffectFilter()
    var chromaticVHS = ChromaticVHSEffectFilter()
    var vcr: VCREffectFilter = VCREffectFilter()
    var vhsTracking: VHSTrackingEffectFilter = VHSTrackingEffectFilter()
    var rbgShiftEdge: RGBShiftEdgeEffectFilter = RGBShiftEdgeEffectFilter()
    var vhsTape: VHSTapeEffectFilter = VHSTapeEffectFilter()
    var vhs: VHSEffectFilter = VHSEffectFilter()
    var grid49: Grid49EffectFilter = Grid49EffectFilter()
    var colorIllusion: ColorIllusionEffectFilter = ColorIllusionEffectFilter()
    var rgbSpark: RGBSparkEffectFilter = RGBSparkEffectFilter()
    var trippy: TrippyEffectFilter = TrippyEffectFilter()
    var shake: ShakeEffectFilter = ShakeEffectFilter()
    var soul: SoulEffectFilter = SoulEffectFilter()
    var spring: SpringEffectFilter = SpringEffectFilter()
    var glitch: GlitchEffectFilter = GlitchEffectFilter()
    var trail: TrailEffectFilter = TrailEffectFilter()
    var hstep: StepEffectFilter = StepEffectFilter(direction: .horizontal)
    var vstep: StepEffectFilter = StepEffectFilter(direction: .vertical)
    var gridColor: GridColorEffectFilter = GridColorEffectFilter()
    var tile: TileEffectFilter = TileEffectFilter()
    var mirror2right: MirrorEffectFilter = MirrorEffectFilter(type: .m2right)
    var mirror4righttop: MirrorEffectFilter = MirrorEffectFilter(type: .m4righttop)
}

// MARK: - NSObject + className
extension NSObject {

    static var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}

// MARK: - PaddingLabel
class PaddingLabel: UILabel {
    var padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let width = size.width + padding.left + padding.right
        let height = size.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        let width = size.width + padding.left + padding.right
        let height = size.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
}
