// // =============================================
// // ENUMS AND CONSTANTS
// // =============================================

// export enum ContentType {
//   VIDEO = 'video',
//   READING = 'reading',
//   ARTICLE = 'article',
//   QUIZ = 'quiz',
//   DISCUSSION = 'discussion',
//   REFLECTION = 'reflection',
//   HANDS_ON = 'handsOn',
//   PROJECT = 'project'
// }

// export enum ResourceType {
//   PRIMARY = 'primary',
//   SECONDARY = 'secondary'
// }

// export enum DifficultyLevel {
//   BEGINNER = 'Beginner',
//   INTERMEDIATE = 'Intermediate',
//   ADVANCED = 'Advanced'
// }

// export enum AssessmentType {
//   QUIZ = 'quiz',
//   ASSIGNMENT = 'assignment',
//   PROJECT = 'project',
//   EXAM = 'exam',
//   TEST = 'test'
// }

// export enum Currency {
//   USD = 'USD',
//   NGN = 'NGN',
//   EUR = 'EUR',
//   GBP = 'GBP'
// }

// export enum Language {
//   ENGLISH = 'English',
//   FRENCH = 'French',
//   YORUBA = 'Yoruba',
//   HAUSA = 'Hausa',
//   IGBO = 'Igbo',
//   SPANISH = 'Spanish'
// }

// export enum CertificationType {
//   COMPLETION = 'Certificate of Completion',
//   PROFESSIONAL = 'Professional Development Certificate',
//   DIGITAL_LITERACY = 'Digital Literacy Certificate',
//   ACCREDITED = 'TRCN Approved Certificate'
// }

// // =============================================
// // INTERFACE DEFINITIONS
// // =============================================

// export interface Duration {
//   totalHours: number;
//   weeks: number;
//   weeklyCommitment: string;
// }

// export interface PriceInfo {
//   amount: number;
//   currency: Currency;
//   discountAmount?: number;
//   discountPercentage?: number;
//   isFree: boolean;
// }

// export interface Rating {
//   score: number; // 0-5
//   totalRatings: number;
//   distribution?: {
//     fiveStar: number;
//     fourStar: number;
//     threeStar: number;
//     twoStar: number;
//     oneStar: number;
//   };
// }

// export interface InstructorSpecialization {
//   name: string;
//   yearsOfExperience: number;
//   certifications: string[];
// }

// export interface PlatformFeature {
//   enabled: boolean;
//   description?: string;
//   limitations?: string[];
// }

// // =============================================
// // BASE ABSTRACT CLASSES
// // =============================================

// export abstract class BaseEntity {
//   readonly id: string;
//   readonly createdAt: Date;
//   updatedAt: Date;
  
//   constructor(id?: string) {
//     this.id = id || this.generateId();
//     this.createdAt = new Date();
//     this.updatedAt = new Date();
//   }
  
//   protected generateId(): string {
//     return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
//   }
  
//   updateTimestamp(): void {
//     this.updatedAt = new Date();
//   }
  
//   abstract validate(): ValidationResult;
// }

// export abstract class ContentItem extends BaseEntity {
//   title: string;
//   description: string;
//   contentType: ContentType;
//   duration: number; // in minutes
//   isPublished: boolean = false;
//   publishDate?: Date;
//   tags: string[] = [];
  
//   constructor(data: Partial<ContentItem>) {
//     super(data.id);
//     Object.assign(this, data);
//   }
  
//   validate(): ValidationResult {
//     const errors: string[] = [];
    
//     if (!this.title || this.title.trim().length < 3) {
//       errors.push('Title must be at least 3 characters long');
//     }
    
//     if (!this.description || this.description.trim().length < 10) {
//       errors.push('Description must be at least 10 characters long');
//     }
    
//     if (this.duration <= 0) {
//       errors.push('Duration must be greater than 0');
//     }
    
//     if (!Object.values(ContentType).includes(this.contentType)) {
//       errors.push(`Invalid content type: ${this.contentType}`);
//     }
    
//     return {
//       isValid: errors.length === 0,
//       errors,
//       warnings: []
//     };
//   }
// }

// // =============================================
// // MAIN DATA CLASSES
// // =============================================

// export class ValidationResult {
//   readonly isValid: boolean;
//   readonly errors: string[];
//   readonly warnings: string[];
//   readonly timestamp: Date;
  
//   constructor(isValid: boolean, errors: string[] = [], warnings: string[] = []) {
//     this.isValid = isValid;
//     this.errors = errors;
//     this.warnings = warnings;
//     this.timestamp = new Date();
//   }
  
//   static success(warnings: string[] = []): ValidationResult {
//     return new ValidationResult(true, [], warnings);
//   }
  
//   static failure(errors: string[], warnings: string[] = []): ValidationResult {
//     return new ValidationResult(false, errors, warnings);
//   }
  
//   combine(other: ValidationResult): ValidationResult {
//     return new ValidationResult(
//       this.isValid && other.isValid,
//       [...this.errors, ...other.errors],
//       [...this.warnings, ...other.warnings]
//     );
//   }
// }

// export class Instructor extends BaseEntity {
//   name: string;
//   bio: string;
//   imageUrl: string;
//   email: string;
//   phone?: string;
//   specialization: InstructorSpecialization[];
//   socialLinks?: {
//     linkedIn?: string;
//     twitter?: string;
//     website?: string;
//   };
//   rating: Rating;
//   coursesTaught: number;
//   isVerified: boolean = false;
  
//   constructor(data: {
//     name: string;
//     bio: string;
//     imageUrl: string;
//     email: string;
//     specialization: InstructorSpecialization[];
//     rating: Rating;
//     coursesTaught: number;
//     id?: string;
//   }) {
//     super(data.id);
    
//     this.name = data.name;
//     this.bio = data.bio;
//     this.imageUrl = data.imageUrl;
//     this.email = data.email;
//     this.specialization = data.specialization;
//     this.rating = data.rating;
//     this.coursesTaught = data.coursesTaught;
    
//     // Validate on creation
//     const validation = this.validate();
//     if (!validation.isValid) {
//       throw new Error(`Invalid Instructor data: ${validation.errors.join(', ')}`);
//     }
//   }
  
//   validate(): ValidationResult {
//     const errors: string[] = [];
//     const warnings: string[] = [];
    
//     // Name validation
//     if (!this.name || this.name.trim().length < 2) {
//       errors.push('Instructor name must be at least 2 characters');
//     }
    
//     // Bio validation
//     if (!this.bio || this.bio.trim().length < 50) {
//       errors.push('Bio must be at least 50 characters');
//     }
    
//     // Email validation
//     const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
//     if (!emailRegex.test(this.email)) {
//       errors.push('Invalid email format');
//     }
    
//     // Image URL validation
//     try {
//       new URL(this.imageUrl);
//     } catch {
//       errors.push('Invalid image URL');
//     }
    
//     // Specialization validation
//     if (!Array.isArray(this.specialization) || this.specialization.length === 0) {
//       errors.push('At least one specialization is required');
//     } else {
//       this.specialization.forEach((spec, index) => {
//         if (!spec.name || spec.name.trim().length === 0) {
//           errors.push(`Specialization ${index + 1} must have a name`);
//         }
//         if (spec.yearsOfExperience < 0) {
//           errors.push(`Specialization ${index + 1} cannot have negative experience`);
//         }
//       });
//     }
    
//     // Rating validation
//     if (this.rating.score < 0 || this.rating.score > 5) {
//       errors.push('Rating score must be between 0 and 5');
//     }
//     if (this.rating.totalRatings < 0) {
//       errors.push('Total ratings cannot be negative');
//     }
    
//     // Courses taught validation
//     if (this.coursesTaught < 0) {
//       errors.push('Courses taught cannot be negative');
//     }
    
//     // Phone validation (if provided)
//     if (this.phone && !/^[\d\s\-\+\(\)]{10,}$/.test(this.phone)) {
//       warnings.push('Phone number format may be invalid');
//     }
    
//     return new ValidationResult(errors.length === 0, errors, warnings);
//   }
  
//   updateRating(newScore: number): void {
//     if (newScore < 0 || newScore > 5) {
//       throw new Error('Rating score must be between 0 and 5');
//     }
    
//     // Calculate new average
//     const totalScore = this.rating.score * this.rating.totalRatings + newScore;
//     this.rating.totalRatings += 1;
//     this.rating.score = totalScore / this.rating.totalRatings;
    
//     this.updateTimestamp();
//   }
  
//   addSpecialization(specialization: InstructorSpecialization): void {
//     if (!specialization.name || specialization.name.trim().length === 0) {
//       throw new Error('Specialization name is required');
//     }
    
//     // Check for duplicates
//     const exists = this.specialization.some(
//       s => s.name.toLowerCase() === specialization.name.toLowerCase()
//     );
    
//     if (exists) {
//       throw new Error(`Specialization "${specialization.name}" already exists`);
//     }
    
//     this.specialization.push(specialization);
//     this.updateTimestamp();
//   }
// }

// export class LearningResource extends ContentItem {
//   url: string;
//   resourceType: ResourceType;
//   author?: string;
//   pages?: number;
//   source?: string;
//   required: boolean = false;
//   downloadUrl?: string;
//   fileSize?: number; // in bytes
  
//   constructor(data: {
//     title: string;
//     description: string;
//     contentType: ContentType;
//     duration: number;
//     url: string;
//     resourceType: ResourceType;
//     id?: string;
//   }) {
//     super(data);
//     this.url = data.url;
//     this.resourceType = data.resourceType;
//   }
  
//   override validate(): ValidationResult {
//     const baseValidation = super.validate();
//     const errors: string[] = [...baseValidation.errors];
    
//     // URL validation
//     try {
//       new URL(this.url);
//     } catch {
//       errors.push('Invalid resource URL');
//     }
    
//     // Resource type validation
//     if (!Object.values(ResourceType).includes(this.resourceType)) {
//       errors.push(`Invalid resource type: ${this.resourceType}`);
//     }
    
//     // File size validation
//     if (this.fileSize !== undefined && this.fileSize < 0) {
//       errors.push('File size cannot be negative');
//     }
    
//     // Pages validation
//     if (this.pages !== undefined && this.pages <= 0) {
//       errors.push('Pages must be greater than 0');
//     }
    
//     return new ValidationResult(
//       errors.length === 0,
//       errors,
//       baseValidation.warnings
//     );
//   }
  
//   getFileSizeFormatted(): string {
//     if (!this.fileSize) return 'Unknown size';
    
//     const units = ['B', 'KB', 'MB', 'GB'];
//     let size = this.fileSize;
//     let unitIndex = 0;
    
//     while (size >= 1024 && unitIndex < units.length - 1) {
//       size /= 1024;
//       unitIndex++;
//     }
    
//     return `${size.toFixed(2)} ${units[unitIndex]}`;
//   }
// }

// export class LearningActivity extends ContentItem {
//   prompt: string;
//   maxPoints?: number;
//   submissionType?: 'text' | 'file' | 'url' | 'none';
//   wordCount?: number;
//   guidelines?: string;
//   dueDays?: number; // Days from chapter start
//   peerReview: boolean = false;
  
//   constructor(data: {
//     title: string;
//     description: string;
//     contentType: ContentType;
//     duration: number;
//     prompt: string;
//     id?: string;
//   }) {
//     super(data);
//     this.prompt = data.prompt;
//   }
  
//   override validate(): ValidationResult {
//     const baseValidation = super.validate();
//     const errors: string[] = [...baseValidation.errors];
    
//     if (!this.prompt || this.prompt.trim().length < 10) {
//       errors.push('Activity prompt must be at least 10 characters');
//     }
    
//     if (this.maxPoints !== undefined && this.maxPoints <= 0) {
//       errors.push('Maximum points must be greater than 0');
//     }
    
//     if (this.wordCount !== undefined && this.wordCount < 0) {
//       errors.push('Word count cannot be negative');
//     }
    
//     if (this.dueDays !== undefined && this.dueDays < 0) {
//       errors.push('Due days cannot be negative');
//     }
    
//     return new ValidationResult(
//       errors.length === 0,
//       errors,
//       baseValidation.warnings
//     );
//   }
  
//   getEstimatedCompletionTime(): string {
//     if (this.duration < 60) {
//       return `${this.duration} minutes`;
//     }
//     const hours = Math.floor(this.duration / 60);
//     const minutes = this.duration % 60;
//     return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
//   }
// }

// export class Topic extends BaseEntity {
//   code: string;
//   title: string;
//   description: string;
//   order: number;
//   resources: LearningResource[] = [];
//   activities: LearningActivity[] = [];
//   prerequisites: string[] = []; // Topic codes
  
//   constructor(data: {
//     code: string;
//     title: string;
//     description: string;
//     order: number;
//     id?: string;
//   }) {
//     super(data.id);
//     this.code = data.code;
//     this.title = data.title;
//     this.description = data.description;
//     this.order = data.order;
//   }
  
//   validate(): ValidationResult {
//     const errors: string[] = [];
//     const warnings: string[] = [];
    
//     // Code validation
//     if (!this.code || !/^[A-Z0-9_]{3,}$/.test(this.code)) {
//       errors.push('Topic code must be at least 3 uppercase alphanumeric characters');
//     }
    
//     // Title validation
//     if (!this.title || this.title.trim().length < 3) {
//       errors.push('Topic title must be at least 3 characters');
//     }
    
//     // Order validation
//     if (this.order < 0) {
//       errors.push('Topic order cannot be negative');
//     }
    
//     // Validate all resources
//     this.resources.forEach((resource, index) => {
//       const validation = resource.validate();
//       if (!validation.isValid) {
//         errors.push(`Resource ${index + 1}: ${validation.errors.join(', ')}`);
//       }
//       warnings.push(...validation.warnings);
//     });
    
//     // Validate all activities
//     this.activities.forEach((activity, index) => {
//       const validation = activity.validate();
//       if (!validation.isValid) {
//         errors.push(`Activity ${index + 1}: ${validation.errors.join(', ')}`);
//       }
//       warnings.push(...validation.warnings);
//     });
    
//     // Check for duplicate resource/activity titles
//     const resourceTitles = this.resources.map(r => r.title.toLowerCase());
//     const duplicateResources = resourceTitles.filter((title, index) => 
//       resourceTitles.indexOf(title) !== index
//     );
//     if (duplicateResources.length > 0) {
//       warnings.push('Duplicate resource titles found');
//     }
    
//     return new ValidationResult(errors.length === 0, errors, warnings);
//   }
  
//   addResource(resource: LearningResource): void {
//     const validation = resource.validate();
//     if (!validation.isValid) {
//       throw new Error(`Invalid resource: ${validation.errors.join(', ')}`);
//     }
    
//     this.resources.push(resource);
//     this.updateTimestamp();
//   }
  
//   addActivity(activity: LearningActivity): void {
//     const validation = activity.validate();
//     if (!validation.isValid) {
//       throw new Error(`Invalid activity: ${validation.errors.join(', ')}`);
//     }
    
//     this.activities.push(activity);
//     this.updateTimestamp();
//   }
  
//   getTotalDuration(): number {
//     const resourceDuration = this.resources.reduce((sum, r) => sum + r.duration, 0);
//     const activityDuration = this.activities.reduce((sum, a) => sum + a.duration, 0);
//     return resourceDuration + activityDuration;
//   }
// }

// export class Chapter extends BaseEntity {
//   chapterNumber: number;
//   code: string;
//   title: string;
//   description: string;
//   duration: string; // e.g., "4 hours"
//   objectives: string[] = [];
//   topics: Topic[] = [];
//   prerequisites: string[] = []; // Chapter codes
  
//   constructor(data: {
//     chapterNumber: number;
//     code: string;
//     title: string;
//     description: string;
//     duration: string;
//     id?: string;
//   }) {
//     super(data.id);
//     this.chapterNumber = data.chapterNumber;
//     this.code = data.code;
//     this.title = data.title;
//     this.description = data.description;
//     this.duration = data.duration;
//   }
  
//   validate(): ValidationResult {
//     const errors: string[] = [];
//     const warnings: string[] = [];
    
//     // Chapter number validation
//     if (this.chapterNumber <= 0) {
//       errors.push('Chapter number must be greater than 0');
//     }
    
//     // Code validation
//     if (!this.code || !/^[A-Z0-9_]{3,}$/.test(this.code)) {
//       errors.push('Chapter code must be at least 3 uppercase alphanumeric characters');
//     }
    
//     // Title validation
//     if (!this.title || this.title.trim().length < 3) {
//       errors.push('Chapter title must be at least 3 characters');
//     }
    
//     // Duration validation
//     if (!this.duration || !/^\d+\s*(hours?|hrs?|minutes?|mins?)$/i.test(this.duration)) {
//       errors.push('Duration must be in format like "4 hours" or "45 minutes"');
//     }
    
//     // Objectives validation
//     if (this.objectives.length === 0) {
//       warnings.push('No learning objectives specified');
//     } else {
//       this.objectives.forEach((obj, index) => {
//         if (!obj || obj.trim().length < 5) {
//           errors.push(`Objective ${index + 1} must be at least 5 characters`);
//         }
//       });
//     }
    
//     // Validate all topics
//     this.topics.forEach((topic, index) => {
//       const validation = topic.validate();
//       if (!validation.isValid) {
//         errors.push(`Topic ${index + 1}: ${validation.errors.join(', ')}`);
//       }
//       warnings.push(...validation.warnings);
//     });
    
//     // Check topic order consistency
//     const topicOrders = this.topics.map(t => t.order);
//     const sortedOrders = [...topicOrders].sort((a, b) => a - b);
//     if (JSON.stringify(topicOrders) !== JSON.stringify(sortedOrders)) {
//       warnings.push('Topics may not be in sequential order');
//     }
    
//     // Check for duplicate topic codes
//     const topicCodes = this.topics.map(t => t.code);
//     const duplicateCodes = topicCodes.filter((code, index) => 
//       topicCodes.indexOf(code) !== index
//     );
//     if (duplicateCodes.length > 0) {
//       errors.push(`Duplicate topic codes found: ${duplicateCodes.join(', ')}`);
//     }
    
//     return new ValidationResult(errors.length === 0, errors, warnings);
//   }
  
//   addTopic(topic: Topic): void {
//     const validation = topic.validate();
//     if (!validation.isValid) {
//       throw new Error(`Invalid topic: ${validation.errors.join(', ')}`);
//     }
    
//     // Check for duplicate topic code
//     const exists = this.topics.some(t => t.code === topic.code);
//     if (exists) {
//       throw new Error(`Topic with code ${topic.code} already exists in this chapter`);
//     }
    
//     this.topics.push(topic);
//     this.updateTimestamp();
//   }
  
//   getTotalDurationInMinutes(): number {
//     return this.topics.reduce((sum, topic) => sum + topic.getTotalDuration(), 0);
//   }
  
//   getResourceCount(): { videos: number; readings: number; activities: number } {
//     let videos = 0;
//     let readings = 0;
//     let activities = 0;
    
//     this.topics.forEach(topic => {
//       topic.resources.forEach(resource => {
//         if (resource.contentType === ContentType.VIDEO) videos++;
//         if ([ContentType.READING, ContentType.ARTICLE].includes(resource.contentType)) readings++;
//       });
//       activities += topic.activities.length;
//     });
    
//     return { videos, readings, activities };
//   }
// }

// export class Assessment extends BaseEntity {
//   title: string;
//   description: string;
//   assessmentType: AssessmentType;
//   totalPoints: number;
//   passingScore: number; // percentage
//   timeLimit?: number; // in minutes
//   questionsCount: number;
//   attemptsAllowed: number = 1;
//   shuffleQuestions: boolean = false;
//   showAnswersAfter: 'never' | 'immediately' | 'after_deadline' | 'after_passing' = 'never';
//   deadline?: Date;
  
//   constructor(data: {
//     title: string;
//     description: string;
//     assessmentType: AssessmentType;
//     totalPoints: number;
//     passingScore: number;
//     questionsCount: number;
//     id?: string;
//   }) {
//     super(data.id);
//     this.title = data.title;
//     this.description = data.description;
//     this.assessmentType = data.assessmentType;
//     this.totalPoints = data.totalPoints;
//     this.passingScore = data.passingScore;
//     this.questionsCount = data.questionsCount;
//   }
  
//   validate(): ValidationResult {
//     const errors: string[] = [];
//     const warnings: string[] = [];
    
//     // Title validation
//     if (!this.title || this.title.trim().length < 3) {
//       errors.push('Assessment title must be at least 3 characters');
//     }
    
//     // Type validation
//     if (!Object.values(AssessmentType).includes(this.assessmentType)) {
//       errors.push(`Invalid assessment type: ${this.assessmentType}`);
//     }
    
//     // Points validation
//     if (this.totalPoints <= 0) {
//       errors.push('Total points must be greater than 0');
//     }
    
//     // Passing score validation
//     if (this.passingScore < 0 || this.passingScore > 100) {
//       errors.push('Passing score must be between 0 and 100');
//     }
    
//     if (this.passingScore > this.totalPoints) {
//       errors.push('Passing score cannot exceed total points');
//     }
    
//     // Questions count validation
//     if (this.questionsCount <= 0) {
//       errors.push('Questions count must be greater than 0');
//     }
    
//     // Time limit validation
//     if (this.timeLimit !== undefined && this.timeLimit <= 0) {
//       errors.push('Time limit must be greater than 0');
//     }
    
//     // Attempts validation
//     if (this.attemptsAllowed < 1) {
//       errors.push('At least 1 attempt must be allowed');
//     }
    
//     // Deadline validation (if set)
//     if (this.deadline && this.deadline < new Date()) {
//       warnings.push('Assessment deadline is in the past');
//     }
    
//     return new ValidationResult(errors.length === 0, errors, warnings);
//   }
  
//   calculateScore(pointsEarned: number): { score: number; percentage: number; passed: boolean } {
//     if (pointsEarned < 0 || pointsEarned > this.totalPoints) {
//       throw new Error(`Points earned must be between 0 and ${this.totalPoints}`);
//     }
    
//     const percentage = (pointsEarned / this.totalPoints) * 100;
//     const passed = percentage >= this.passingScore;
    
//     return {
//       score: pointsEarned,
//       percentage: Number(percentage.toFixed(2)),
//       passed
//     };
//   }
  
//   isAvailable(): { available: boolean; reason?: string } {
//     const now = new Date();
    
//     if (this.deadline && now > this.deadline) {
//       return { available: false, reason: 'Deadline has passed' };
//     }
    
//     return { available: true };
//   }
// }

// export class Certification {
//   readonly type: CertificationType;
//   readonly issuer: string;
//   readonly accreditation?: string;
//   readonly verified: boolean = false;
//   readonly issueDate?: Date;
//   readonly expiryDate?: Date;
//   readonly credentialId?: string;
  
//   constructor(data: {
//     type: CertificationType;
//     issuer: string;
//     accreditation?: string;
//     verified?: boolean;
//     issueDate?: Date;
//     expiryDate?: Date;
//     credentialId?: string;
//   }) {
//     this.type = data.type;
//     this.issuer = data.issuer;
//     this.accreditation = data.accreditation;
//     this.verified = data.verified ?? false;
//     this.issueDate = data.issueDate;
//     this.expiryDate = data.expiryDate;
//     this.credentialId = data.credentialId;
    
//     // Validate dates
//     if (this.issueDate && this.expiryDate && this.issueDate > this.expiryDate) {
//       throw new Error('Issue date cannot be after expiry date');
//     }
    
//     if (this.expiryDate && this.expiryDate < new Date()) {
//       console.warn('Certification has expired');
//     }
//   }
  
//   isValid(): boolean {
//     if (!this.verified) return false;
//     if (this.expiryDate && this.expiryDate < new Date()) return false;
//     return true;
//   }
  
//   getValidityPeriod(): string | null {
//     if (!this.issueDate || !this.expiryDate) return null;
    
//     const diffTime = Math.abs(this.expiryDate.getTime() - this.issueDate.getTime());
//     const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
//     if (diffDays < 30) {
//       return `${diffDays} days`;
//     } else if (diffDays < 365) {
//       const months = Math.floor(diffDays / 30);
//       return `${months} month${months !== 1 ? 's' : ''}`;
//     } else {
//       const years = Math.floor(diffDays / 365);
//       return `${years} year${years !== 1 ? 's' : ''}`;
//     }
//   }
// }

// export class CourseStructure {
//   readonly totalChapters: number;
//   readonly chaptersPerWeek: number;
//   readonly assignments: number;
//   readonly quizzes: number;
//   readonly midTermTests: number;
//   readonly finalExam: boolean;
//   readonly certificationProject: boolean;
  
//   constructor(data: {
//     totalChapters: number;
//     chaptersPerWeek: number;
//     assignments: number;
//     quizzes: number;
//     midTermTests: number;
//     finalExam: boolean;
//     certificationProject: boolean;
//   }) {
//     this.totalChapters = data.totalChapters;
//     this.chaptersPerWeek = data.chaptersPerWeek;
//     this.assignments = data.assignments;
//     this.quizzes = data.quizzes;
//     this.midTermTests = data.midTermTests;
//     this.finalExam = data.finalExam;
//     this.certificationProject = data.certificationProject;
    
//     // Validate structure
//     if (this.totalChapters <= 0) {
//       throw new Error('Total chapters must be greater than 0');
//     }
    
//     if (this.chaptersPerWeek <= 0 || this.chaptersPerWeek > this.totalChapters) {
//       throw new Error('Invalid chapters per week');
//     }
    
//     if (this.assignments < 0 || this.quizzes < 0 || this.midTermTests < 0) {
//       throw new Error('Assessment counts cannot be negative');
//     }
//   }
  
//   getEstimatedDurationWeeks(): number {
//     return Math.ceil(this.totalChapters / this.chaptersPerWeek);
//   }
  
//   getTotalAssessments(): number {
//     return this.assignments + this.quizzes + this.midTermTests + 
//            (this.finalExam ? 1 : 0) + (this.certificationProject ? 1 : 0);
//   }
// }

// export class GradingPolicy {
//   readonly totalPoints: number;
//   readonly breakdown: Map<string, number>; // Assessment type -> points
//   readonly gradeScale: Map<string, [number, number]>; // Grade -> [min, max]
//   readonly certificationRequirements: string[];
  
//   constructor(data: {
//     totalPoints: number;
//     breakdown: Record<string, number>;
//     gradeScale: Record<string, [number, number]>;
//     certificationRequirements: string[];
//   }) {
//     this.totalPoints = data.totalPoints;
//     this.breakdown = new Map(Object.entries(data.breakdown));
//     this.gradeScale = new Map(Object.entries(data.gradeScale));
//     this.certificationRequirements = data.certificationRequirements;
    
//     // Validate total points match breakdown
//     const breakdownTotal = Array.from(this.breakdown.values()).reduce((sum, points) => sum + points, 0);
//     if (breakdownTotal !== this.totalPoints) {
//       throw new Error(`Breakdown total (${breakdownTotal}) does not match total points (${this.totalPoints})`);
//     }
    
//     // Validate grade scale
//     let prevMax = -1;
//     for (const [grade, [min, max]] of this.gradeScale) {
//       if (min < 0 || max > 100 || min > max) {
//         throw new Error(`Invalid grade scale for ${grade}: ${min}-${max}`);
//       }
//       if (min <= prevMax) {
//         throw new Error(`Grade scales overlap: ${grade}`);
//       }
//       prevMax = max;
//     }
//   }
  
//   calculateGrade(percentage: number): string {
//     if (percentage < 0 || percentage > 100) {
//       throw new Error('Percentage must be between 0 and 100');
//     }
    
//     for (const [grade, [min, max]] of this.gradeScale) {
//       if (percentage >= min && percentage <= max) {
//         return grade;
//       }
//     }
    
//     return 'F'; // Default if no match
//   }
  
//   getBreakdownPercentage(): Record<string, number> {
//     const result: Record<string, number> = {};
    
//     for (const [type, points] of this.breakdown) {
//       result[type] = (points / this.totalPoints) * 100;
//     }
    
//     return result;
//   }
// }

// export class Course extends BaseEntity {
//   readonly code: string;
//   readonly title: string;
//   readonly subtitle: string;
//   readonly description: string;
//   readonly longDescription: string;
//   readonly imageUrl: string;
//   readonly bannerUrl: string;
//   readonly instructor: Instructor;
//   readonly category: string;
//   readonly subCategory?: string;
//   readonly price: PriceInfo;
//   readonly rating: Rating;
//   readonly enrollmentCount: number;
//   readonly difficulty: DifficultyLevel;
//   readonly duration: Duration;
//   readonly certification?: Certification;
//   readonly prerequisites: string[];
//   readonly learningOutcomes: string[];
//   readonly targetAudience: string[];
//   readonly language: Language;
//   readonly subtitles: Language[];
//   readonly features: string[];
//   readonly lastUpdated: Date;
//   readonly platformFeatures: {
//     discussionForums: PlatformFeature;
//     liveSessions: PlatformFeature;
//     officeHours: PlatformFeature;
//     peerReview: PlatformFeature;
//     badges: PlatformFeature;
//     progressTracking: PlatformFeature;
//   };
  
//   // Course content
//   readonly structure: CourseStructure;
//   readonly chapters: Chapter[];
//   readonly assessments: {
//     weeklyQuizzes: Assessment[];
//     midTermTests: Assessment[];
//     finalExam?: Assessment;
//     certificationProject?: Assessment;
//   };
//   readonly gradingPolicy: GradingPolicy;
//   readonly resources: {
//     textbook?: {
//       title: string;
//       author: string;
//       edition: string;
//       isbn: string;
//       optional: boolean;
//     };
//     toolkit?: {
//       title: string;
//       includes: string[];
//       downloadUrl: string;
//     };
//     videoLibrary?: {
//       totalVideos: number;
//       categories: string[];
//       averageDuration: string;
//     };
//   };
  
//   constructor(data: {
//     code: string;
//     title: string;
//     subtitle: string;
//     description: string;
//     longDescription: string;
//     imageUrl: string;
//     bannerUrl: string;
//     instructor: Instructor;
//     category: string;
//     price: PriceInfo;
//     rating: Rating;
//     enrollmentCount: number;
//     difficulty: DifficultyLevel;
//     duration: Duration;
//     prerequisites: string[];
//     learningOutcomes: string[];
//     targetAudience: string[];
//     language: Language;
//     features: string[];
//     structure: CourseStructure;
//     chapters: Chapter[];
//     assessments: {
//       weeklyQuizzes: Assessment[];
//       midTermTests: Assessment[];
//       finalExam?: Assessment;
//       certificationProject?: Assessment;
//     };
//     gradingPolicy: GradingPolicy;
//     id?: string;
//   }) {
//     super(data.id);
    
//     // Assign all properties
//     Object.assign(this, {
//       ...data,
//       lastUpdated: new Date(),
//       subtitles: [Language.ENGLISH], // Default
//       platformFeatures: this.getDefaultPlatformFeatures()
//     });
    
//     // Validate on creation
//     const validation = this.validate();
//     if (!validation.isValid) {
//       throw new Error(`Invalid Course data: ${validation.errors.join(', ')}`);
//     }
//   }
  
//   private getDefaultPlatformFeatures() {
//     return {
//       discussionForums: { enabled: true, description: 'Peer discussion and Q&A' },
//       liveSessions: { enabled: true, description: 'Weekly live sessions with instructor' },
//       officeHours: { enabled: true, description: 'Scheduled one-on-one support' },
//       peerReview: { enabled: true, description: 'Peer feedback on assignments' },
//       badges: { enabled: true, description: 'Achievement badges for milestones' },
//       progressTracking: { enabled: true, description: 'Visual progress dashboard' }
//     };
//   }
  
//   validate(): ValidationResult {
//     const errors: string[] = [];
//     const warnings: string[] = [];
    
//     // Code validation
//     if (!this.code || !/^[A-Z0-9_]{3,}$/.test(this.code)) {
//       errors.push('Course code must be at least 3 uppercase alphanumeric characters');
//     }
    
//     // Title validation
//     if (!this.title || this.title.trim().length < 5) {
//       errors.push('Course title must be at least 5 characters');
//     }
    
//     // Description validation
//     if (!this.description || this.description.trim().length < 20) {
//       errors.push('Course description must be at least 20 characters');
//     }
    
//     if (!this.longDescription || this.longDescription.trim().length < 100) {
//       errors.push('Course long description must be at least 100 characters');
//     }
    
//     // URL validation
//     try {
//       new URL(this.imageUrl);
//       new URL(this.bannerUrl);
//     } catch {
//       errors.push('Invalid image or banner URL');
//     }
    
//     // Instructor validation
//     const instructorValidation = this.instructor.validate();
//     if (!instructorValidation.isValid) {
//       errors.push(`Instructor: ${instructorValidation.errors.join(', ')}`);
//     }
//     warnings.push(...instructorValidation.warnings);
    
//     // Price validation
//     if (this.price.amount < 0) {
//       errors.push('Price amount cannot be negative');
//     }
    
//     if (this.price.discountAmount && this.price.discountAmount > this.price.amount) {
//       errors.push('Discount cannot exceed original price');
//     }
    
//     if (this.price.discountPercentage && (this.price.discountPercentage < 0 || this.price.discountPercentage > 100)) {
//       errors.push('Discount percentage must be between 0 and 100');
//     }
    
//     // Enrollment validation
//     if (this.enrollmentCount < 0) {
//       errors.push('Enrollment count cannot be negative');
//     }
    
//     // Difficulty validation
//     if (!Object.values(DifficultyLevel).includes(this.difficulty)) {
//       errors.push(`Invalid difficulty level: ${this.difficulty}`);
//     }
    
//     // Duration validation
//     if (this.duration.totalHours <= 0) {
//       errors.push('Total hours must be greater than 0');
//     }
    
//     if (this.duration.weeks <= 0) {
//       errors.push('Weeks must be greater than 0');
//     }
    
//     // Prerequisites validation
//     if (this.prerequisites.some(p => !p || p.trim().length === 0)) {
//       errors.push('Prerequisites cannot contain empty strings');
//     }
    
//     // Learning outcomes validation
//     if (this.learningOutcomes.length === 0) {
//       warnings.push('No learning outcomes specified');
//     } else {
//       this.learningOutcomes.forEach((outcome, index) => {
//         if (!outcome || outcome.trim().length < 10) {
//           errors.push(`Learning outcome ${index + 1} must be at least 10 characters`);
//         }
//       });
//     }
    
//     // Target audience validation
//     if (this.targetAudience.length === 0) {
//       warnings.push('No target audience specified');
//     }
    
//     // Language validation
//     if (!Object.values(Language).includes(this.language)) {
//       errors.push(`Invalid language: ${this.language}`);
//     }
    
//     // Features validation
//     if (this.features.length === 0) {
//       warnings.push('No features specified');
//     }
    
//     // Validate all chapters
//     if (this.chapters.length === 0) {
//       errors.push('Course must have at least one chapter');
//     } else {
//       this.chapters.forEach((chapter, index) => {
//         const validation = chapter.validate();
//         if (!validation.isValid) {
//           errors.push(`Chapter ${index + 1}: ${validation.errors.join(', ')}`);
//         }
//         warnings.push(...validation.warnings);
//       });
      
//       // Check chapter order consistency
//       const chapterNumbers = this.chapters.map(c => c.chapterNumber);
//       const sortedNumbers = [...chapterNumbers].sort((a, b) => a - b);
//       if (JSON.stringify(chapterNumbers) !== JSON.stringify(sortedNumbers)) {
//         warnings.push('Chapters may not be in sequential order');
//       }
      
//       // Check for duplicate chapter numbers or codes
//       const chapterCodes = this.chapters.map(c => c.code);
//       const duplicateCodes = chapterCodes.filter((code, index) => 
//         chapterCodes.indexOf(code) !== index
//       );
//       if (duplicateCodes.length > 0) {
//         errors.push(`Duplicate chapter codes: ${duplicateCodes.join(', ')}`);
//       }
      
//       // Validate structure matches chapters
//       if (this.structure.totalChapters !== this.chapters.length) {
//         errors.push(`Structure expects ${this.structure.totalChapters} chapters, but found ${this.chapters.length}`);
//       }
//     }
    
//     // Validate assessments
//     if (this.assessments.weeklyQuizzes.length !== this.structure.quizzes) {
//       warnings.push(`Expected ${this.structure.quizzes} quizzes, found ${this.assessments.weeklyQuizzes.length}`);
//     }
    
//     if (this.assessments.midTermTests.length !== this.structure.midTermTests) {
//       warnings.push(`Expected ${this.structure.midTermTests} mid-term tests, found ${this.assessments.midTermTests.length}`);
//     }
    
//     if (this.structure.finalExam && !this.assessments.finalExam) {
//       errors.push('Final exam is required by structure but not provided');
//     }
    
//     if (this.structure.certificationProject && !this.assessments.certificationProject) {
//       errors.push('Certification project is required by structure but not provided');
//     }
    
//     // Validate all assessments
//     [...this.assessments.weeklyQuizzes, ...this.assessments.midTermTests].forEach((assessment, index) => {
//       const validation = assessment.validate();
//       if (!validation.isValid) {
//         errors.push(`Assessment ${index + 1}: ${validation.errors.join(', ')}`);
//       }
//     });
    
//     if (this.assessments.finalExam) {
//       const validation = this.assessments.finalExam.validate();
//       if (!validation.isValid) {
//         errors.push(`Final exam: ${validation.errors.join(', ')}`);
//       }
//     }
    
//     if (this.assessments.certificationProject) {
//       const validation = this.assessments.certificationProject.validate();
//       if (!validation.isValid) {
//         errors.push(`Certification project: ${validation.errors.join(', ')}`);
//       }
//     }
    
//     return new ValidationResult(errors.length === 0, errors, warnings);
//   }
  
//   getTotalDurationInHours(): number {
//     return this.chapters.reduce((sum, chapter) => {
//       return sum + chapter.getTotalDurationInMinutes() / 60;
//     }, 0);
//   }
  
//   getResourceSummary(): {
//     totalChapters: number;
//     totalTopics: number;
//     totalVideos: number;
//     totalReadings: number;
//     totalActivities: number;
//     totalAssessments: number;
//   } {
//     let totalTopics = 0;
//     let totalVideos = 0;
//     let totalReadings = 0;
//     let totalActivities = 0;
    
//     this.chapters.forEach(chapter => {
//       totalTopics += chapter.topics.length;
//       const resources = chapter.getResourceCount();
//       totalVideos += resources.videos;
//       totalReadings += resources.readings;
//       totalActivities += resources.activities;
//     });
    
//     const totalAssessments = this.structure.getTotalAssessments();
    
//     return {
//       totalChapters: this.chapters.length,
//       totalTopics,
//       totalVideos,
//       totalReadings,
//       totalActivities,
//       totalAssessments
//     };
//   }
  
//   getEstimatedCompletionTime(): string {
//     const totalMinutes = this.getTotalDurationInHours() * 60;
//     const weeks = Math.ceil(totalMinutes / (this.duration.weeklyCommitment ? 
//       parseInt(this.duration.weeklyCommitment) * 60 : 420)); // Default 7 hours/week
    
//     return `${weeks} week${weeks !== 1 ? 's' : ''}`;
//   }
  
//   isEligibleForCertification(studentProgress: {
//     completedChapters: number;
//     completedAssignments: number;
//     completedQuizzes: number;
//     completedTests: number;
//     finalExamScore?: number;
//     projectScore?: number;
//   }): { eligible: boolean; missingRequirements: string[] } {
//     const missing: string[] = [];
    
//     // Check chapter completion
//     if (studentProgress.completedChapters < this.chapters.length) {
//       missing.push(`Complete all chapters (${studentProgress.completedChapters}/${this.chapters.length})`);
//     }
    
//     // Check assignment completion
//     if (studentProgress.completedAssignments < this.structure.assignments) {
//       missing.push(`Complete all assignments (${studentProgress.completedAssignments}/${this.structure.assignments})`);
//     }
    
//     // Check quiz completion
//     if (studentProgress.completedQuizzes < this.structure.quizzes) {
//       missing.push(`Complete all quizzes (${studentProgress.completedQuizzes}/${this.structure.quizzes})`);
//     }
    
//     // Check test completion
//     if (studentProgress.completedTests < this.structure.midTermTests) {
//       missing.push(`Complete all tests (${studentProgress.completedTests}/${this.structure.midTermTests})`);
//     }
    
//     // Check final exam if required
//     if (this.structure.finalExam && !studentProgress.finalExamScore) {
//       missing.push('Complete final exam');
//     } else if (this.structure.finalExam && studentProgress.finalExamScore < 70) {
//       missing.push('Pass final exam (minimum 70%)');
//     }
    
//     // Check certification project if required
//     if (this.structure.certificationProject && !studentProgress.projectScore) {
//       missing.push('Complete certification project');
//     } else if (this.structure.certificationProject && studentProgress.projectScore < 80) {
//       missing.push('Pass certification project (minimum 80%)');
//     }
    
//     return {
//       eligible: missing.length === 0,
//       missingRequirements: missing
//     };
//   }
// }

// // =============================================
// // BUILDER PATTERN FOR COMPLEX OBJECTS
// // =============================================

// export class CourseBuilder {
//   private courseData: Partial<{
//     code: string;
//     title: string;
//     subtitle: string;
//     description: string;
//     longDescription: string;
//     imageUrl: string;
//     bannerUrl: string;
//     instructor: Instructor;
//     category: string;
//     subCategory: string;
//     price: PriceInfo;
//     rating: Rating;
//     enrollmentCount: number;
//     difficulty: DifficultyLevel;
//     duration: Duration;
//     prerequisites: string[];
//     learningOutcomes: string[];
//     targetAudience: string[];
//     language: Language;
//     subtitles: Language[];
//     features: string[];
//     structure: CourseStructure;
//     chapters: Chapter[];
//     assessments: {
//       weeklyQuizzes: Assessment[];
//       midTermTests: Assessment[];
//       finalExam?: Assessment;
//       certificationProject?: Assessment;
//     };
//     gradingPolicy: GradingPolicy;
//     certification?: Certification;
//     resources: Course['resources'];
//   }> = {};
  
//   constructor() {
//     // Set defaults
//     this.courseData.language = Language.ENGLISH;
//     this.courseData.subtitles = [Language.ENGLISH];
//     this.courseData.enrollmentCount = 0;
//     this.courseData.prerequisites = [];
//     this.courseData.features = [];
//     this.courseData.chapters = [];
//     this.courseData.assessments = {
//       weeklyQuizzes: [],
//       midTermTests: []
//     };
//   }
  
//   setBasicInfo(code: string, title: string, description: string): CourseBuilder {
//     this.courseData.code = code;
//     this.courseData.title = title;
//     this.courseData.description = description;
//     return this;
//   }
  
//   setInstructor(instructor: Instructor): CourseBuilder {
//     this.courseData.instructor = instructor;
//     return this;
//   }
  
//   setPricing(amount: number, currency: Currency, discountAmount?: number): CourseBuilder {
//     this.courseData.price = {
//       amount,
//       currency,
//       discountAmount,
//       discountPercentage: discountAmount ? (discountAmount / amount) * 100 : undefined,
//       isFree: amount === 0
//     };
//     return this;
//   }
  
//   setDifficulty(difficulty: DifficultyLevel): CourseBuilder {
//     this.courseData.difficulty = difficulty;
//     return this;
//   }
  
//   setDuration(totalHours: number, weeks: number, weeklyCommitment: string): CourseBuilder {
//     this.courseData.duration = { totalHours, weeks, weeklyCommitment };
//     return this;
//   }
  
//   addChapter(chapter: Chapter): CourseBuilder {
//     if (!this.courseData.chapters) {
//       this.courseData.chapters = [];
//     }
//     this.courseData.chapters.push(chapter);
//     return this;
//   }
  
//   setStructure(structure: CourseStructure): CourseBuilder {
//     this.courseData.structure = structure;
//     return this;
//   }
  
//   setGradingPolicy(policy: GradingPolicy): CourseBuilder {
//     this.courseData.gradingPolicy = policy;
//     return this;
//   }
  
//   addAssessment(assessment: Assessment, type: 'quiz' | 'test' | 'final' | 'project'): CourseBuilder {
//     if (!this.courseData.assessments) {
//       this.courseData.assessments = {
//         weeklyQuizzes: [],
//         midTermTests: []
//       };
//     }
    
//     switch (type) {
//       case 'quiz':
//         this.courseData.assessments.weeklyQuizzes.push(assessment);
//         break;
//       case 'test':
//         this.courseData.assessments.midTermTests.push(assessment);
//         break;
//       case 'final':
//         this.courseData.assessments.finalExam = assessment;
//         break;
//       case 'project':
//         this.courseData.assessments.certificationProject = assessment;
//         break;
//     }
    
//     return this;
//   }
  
//   build(): Course {
//     // Validate required fields
//     const requiredFields = [
//       'code', 'title', 'description', 'longDescription', 'imageUrl', 'bannerUrl',
//       'instructor', 'category', 'price', 'rating', 'difficulty', 'duration',
//       'structure', 'chapters', 'gradingPolicy'
//     ];
    
//     const missingFields = requiredFields.filter(field => !this.courseData[field]);
//     if (missingFields.length > 0) {
//       throw new Error(`Missing required fields: ${missingFields.join(', ')}`);
//     }
    
//     // Ensure arrays are initialized
//     this.courseData.prerequisites = this.courseData.prerequisites || [];
//     this.courseData.learningOutcomes = this.courseData.learningOutcomes || [];
//     this.courseData.targetAudience = this.courseData.targetAudience || [];
//     this.courseData.features = this.courseData.features || [];
//     this.courseData.subtitles = this.courseData.subtitles || [Language.ENGLISH];
    
//     // Ensure assessments structure
//     if (!this.courseData.assessments) {
//       this.courseData.assessments = {
//         weeklyQuizzes: [],
//         midTermTests: []
//       };
//     }
    
//     // Create course instance
//     return new Course({
//       code: this.courseData.code!,
//       title: this.courseData.title!,
//       subtitle: this.courseData.subtitle || '',
//       description: this.courseData.description!,
//       longDescription: this.courseData.longDescription!,
//       imageUrl: this.courseData.imageUrl!,
//       bannerUrl: this.courseData.bannerUrl!,
//       instructor: this.courseData.instructor!,
//       category: this.courseData.category!,
//       price: this.courseData.price!,
//       rating: this.courseData.rating!,
//       enrollmentCount: this.courseData.enrollmentCount || 0,
//       difficulty: this.courseData.difficulty!,
//       duration: this.courseData.duration!,
//       prerequisites: this.courseData.prerequisites,
//       learningOutcomes: this.courseData.learningOutcomes,
//       targetAudience: this.courseData.targetAudience,
//       language: this.courseData.language!,
//       features: this.courseData.features,
//       structure: this.courseData.structure!,
//       chapters: this.courseData.chapters!,
//       assessments: this.courseData.assessments,
//       gradingPolicy: this.courseData.gradingPolicy!,
//       id: `course_${Date.now()}`
//     });
//   }
// }

// // =============================================
// // FACTORY PATTERN FOR COMMON OBJECTS
// // =============================================

// export class CourseFactory {
//   static createDefaultGradingPolicy(): GradingPolicy {
//     return new GradingPolicy({
//       totalPoints: 1000,
//       breakdown: {
//         'Chapter Assignments': 360,
//         'Weekly Quizzes': 120,
//         'Mid-Term Tests': 200,
//         'Final Exam': 200,
//         'Certification Project': 120
//       },
//       gradeScale: {
//         'A': [90, 100],
//         'B': [80, 89],
//         'C': [70, 79],
//         'D': [60, 69],
//         'F': [0, 59]
//       },
//       certificationRequirements: [
//         'Complete all chapter assignments',
//         'Score 70% or higher on final exam',
//         'Score 80% or higher on certification project',
//         'Overall course grade of 75% or higher'
//       ]
//     });
//   }
  
//   static createDefaultStructure(totalChapters: number): CourseStructure {
//     return new CourseStructure({
//       totalChapters,
//       chaptersPerWeek: Math.min(2, totalChapters),
//       assignments: totalChapters,
//       quizzes: Math.ceil(totalChapters / 2),
//       midTermTests: Math.ceil(totalChapters / 6),
//       finalExam: true,
//       certificationProject: true
//     });
//   }
  
//   static createFreeCourse(
//     code: string,
//     title: string,
//     description: string,
//     instructor: Instructor,
//     category: string,
//     difficulty: DifficultyLevel
//   ): CourseBuilder {
//     const builder = new CourseBuilder();
    
//     return builder
//       .setBasicInfo(code, title, description)
//       .setInstructor(instructor)
//       .setPricing(0, Currency.USD)
//       .setDifficulty(difficulty)
//       .setDuration(45, 6, '7-8 hours');
//   }
// }

// // =============================================
// // VALIDATOR UTILITIES
// // =============================================

// export class Validators {
//   static validateEmail(email: string): boolean {
//     const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
//     return regex.test(email);
//   }
  
//   static validateUrl(url: string): boolean {
//     try {
//       new URL(url);
//       return true;
//     } catch {
//       return false;
//     }
//   }
  
//   static validatePhone(phone: string): boolean {
//     // Basic international phone validation
//     const regex = /^[\d\s\-\+\(\)]{10,}$/;
//     return regex.test(phone);
//   }
  
//   static validatePercentage(value: number): boolean {
//     return value >= 0 && value <= 100;
//   }
  
//   static validateRating(value: number): boolean {
//     return value >= 0 && value <= 5;
//   }
  
//   static validateNotEmpty(value: string): boolean {
//     return value.trim().length > 0;
//   }
  
//   static validateMinLength(value: string, min: number): boolean {
//     return value.trim().length >= min;
//   }
  
//   static validateMaxLength(value: string, max: number): boolean {
//     return value.trim().length <= max;
//   }
  
//   static validatePositiveNumber(value: number): boolean {
//     return value >= 0;
//   }
  
//   static validateStrictlyPositiveNumber(value: number): boolean {
//     return value > 0;
//   }
// }

// // =============================================
// // ERROR CLASSES
// // =============================================

// export class ValidationError extends Error {
//   readonly errors: string[];
//   readonly warnings: string[];
//   readonly timestamp: Date;
  
//   constructor(message: string, errors: string[] = [], warnings: string[] = []) {
//     super(message);
//     this.name = 'ValidationError';
//     this.errors = errors;
//     this.warnings = warnings;
//     this.timestamp = new Date();
//   }
// }

// export class BusinessRuleError extends Error {
//   readonly rule: string;
//   readonly context: Record<string, any>;
  
//   constructor(message: string, rule: string, context: Record<string, any> = {}) {
//     super(message);
//     this.name = 'BusinessRuleError';
//     this.rule = rule;
//     this.context = context;
//   }
// }

// export class ResourceNotFoundError extends Error {
//   readonly resourceType: string;
//   readonly resourceId: string;
  
//   constructor(resourceType: string, resourceId: string) {
//     super(`${resourceType} with ID ${resourceId} not found`);
//     this.name = 'ResourceNotFoundError';
//     this.resourceType = resourceType;
//     this.resourceId = resourceId;
//   }
// }

// // =============================================
// // UTILITY FUNCTIONS
// // =============================================

// export function formatDuration(minutes: number): string {
//   if (minutes < 60) {
//     return `${minutes} minute${minutes !== 1 ? 's' : ''}`;
//   }
  
//   const hours = Math.floor(minutes / 60);
//   const remainingMinutes = minutes % 60;
  
//   if (remainingMinutes === 0) {
//     return `${hours} hour${hours !== 1 ? 's' : ''}`;
//   }
  
//   return `${hours} hour${hours !== 1 ? 's' : ''} ${remainingMinutes} minute${remainingMinutes !== 1 ? 's' : ''}`;
// }

// export function calculateDiscountPercentage(original: number, discounted: number): number {
//   if (original <= 0) throw new Error('Original price must be greater than 0');
//   if (discounted > original) throw new Error('Discounted price cannot exceed original price');
  
//   return ((original - discounted) / original) * 100;
// }

// export function generateCourseCode(category: string, sequence: number): string {
//   const prefix = category.slice(0, 3).toUpperCase();
//   return `${prefix}_${sequence.toString().padStart(3, '0')}`;
// }

// // =============================================
// // TYPE GUARDS
// // =============================================

// export function isContentType(value: any): value is ContentType {
//   return Object.values(ContentType).includes(value);
// }

// export function isDifficultyLevel(value: any): value is DifficultyLevel {
//   return Object.values(DifficultyLevel).includes(value);
// }

// export function isAssessmentType(value: any): value is AssessmentType {
//   return Object.values(AssessmentType).includes(value);
// }

// export function isCurrency(value: any): value is Currency {
//   return Object.values(Currency).includes(value);
// }

// export function isLanguage(value: any): value is Language {
//   return Object.values(Language).includes(value);
// }

// // =============================================
// // EXAMPLE USAGE
// // =============================================

// /*
// // Creating an instructor
// const instructor = new Instructor({
//   name: 'Dr. Chinedu Okonkwo',
//   bio: 'Professor of STEM Education at University of Lagos with 15+ years experience in curriculum development',
//   imageUrl: 'https://example.com/instructor.jpg',
//   email: 'c.okonkwo@unilag.edu.ng',
//   specialization: [
//     { name: 'STEM Education', yearsOfExperience: 15, certifications: ['PhD Education'] },
//     { name: 'Curriculum Design', yearsOfExperience: 10, certifications: ['Curriculum Specialist'] }
//   ],
//   rating: { score: 4.9, totalRatings: 1243 },
//   coursesTaught: 42
// });

// // Creating a course using builder pattern
// const course = new CourseBuilder()
//   .setBasicInfo(
//     'STM_101',
//     'S.T.E.A.M. Education Fundamentals',
//     'A comprehensive introduction to S.T.E.A.M. education'
//   )
//   .setInstructor(instructor)
//   .setPricing(0, Currency.USD)
//   .setDifficulty(DifficultyLevel.BEGINNER)
//   .setDuration(45, 6, '7-8 hours')
//   .setStructure(CourseFactory.createDefaultStructure(12))
//   .setGradingPolicy(CourseFactory.createDefaultGradingPolicy())
//   .build();

// // Validating the course
// const validation = course.validate();
// if (!validation.isValid) {
//   console.error('Course validation failed:', validation.errors);
// } else if (validation.warnings.length > 0) {
//   console.warn('Course validation warnings:', validation.warnings);
// }

// // Getting course summary
// const summary = course.getResourceSummary();
// console.log('Course summary:', summary);
// */